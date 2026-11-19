import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/nutrition/detected_food.dart';
import '../domain/nutrition/food_catalog.dart';

/// Client ke 9router (OpenAI-compatible) untuk analisis gizi foto makanan.
///
/// Base URL dapat dioverride lewat `--dart-define=NURI_AI_BASE_URL=...`,
/// API key lewat `NURI_AI_API_KEY`, dan model lewat `NURI_AI_MODEL`.
class FoodAiService {
  static const String _envBaseUrl = String.fromEnvironment('NURI_AI_BASE_URL');
  static const String _envApiKey = String.fromEnvironment('NURI_AI_API_KEY');
  static const String _envModel = String.fromEnvironment('NURI_AI_MODEL');

  static const String _defaultApiKey = 'sk-ce8079450db410ef-jz8xkz-20a43860';
  static const String _defaultModel = 'ag/gemini-3.8-flash';

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    // Emulator Android memetakan host PC ke 10.0.2.2.
    if (Platform.isAndroid) return 'http://10.0.2.2:20128/v1';
    return 'http://127.0.0.1:20128/v1';
  }

  static String get apiKey =>
      _envApiKey.isNotEmpty ? _envApiKey : _defaultApiKey;

  static String get model => _envModel.isNotEmpty ? _envModel : _defaultModel;

  static const String _prompt =
      'Analisis setiap makanan/minuman pada foto ini untuk aplikasi nutrisi '
      'anak dan ibu di Indonesia (NURI). Identifikasi setiap komponen makanan '
      'secara terpisah (misal nasi, lauk, sayur, buah). '
      'Kembalikan HANYA JSON array tanpa markdown dan tanpa komentar: '
      '[{"name": "Nama Makanan", '
      '"grams": perkiraan_berat_dalam_gram_number, '
      '"category": "Makanan Pokok|Lauk Hewani|Lauk Nabati|Sayuran|Buah|Minuman|Lainnya", '
      '"energyKcal": kcal_per_100g_number, '
      '"proteinG": protein_per_100g_number, '
      '"fatG": lemak_per_100g_number, '
      '"carbG": karbohidrat_per_100g_number, '
      '"ironMg": besi_per_100g_number, '
      '"zincMg": zinc_per_100g_number, '
      '"confidence": 0.0_sampai_1.0_number}]. '
      'Semua angka gizi adalah PER 100 GRAM, bukan total porsi. '
      'Jika tidak ada makanan pada foto, kembalikan [].';

  /// Analisis file gambar, hasilkan daftar makanan yang terdeteksi.
  static Future<List<DetectedFood>> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final b64 = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };

    final body = jsonEncode({
      'model': model,
      'stream': false,
      'max_tokens': 1200,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mime;base64,$b64'},
            },
          ],
        },
      ],
    });

    final http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/chat/completions'),
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $apiKey',
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 60));
    } on SocketException {
      throw const FoodAiException(
        'Tidak dapat terhubung ke server AI. Pastikan 9router berjalan.',
      );
    } catch (e) {
      throw FoodAiException('Gagal menghubungi server AI: $e');
    }

    if (res.statusCode != 200) {
      throw FoodAiException(
        'Server AI menolak permintaan (${res.statusCode}).',
      );
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw const FoodAiException('Server AI tidak mengembalikan hasil.');
    }
    final message = (choices.first as Map)['message'] as Map?;
    final content = message?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw const FoodAiException('Server AI mengembalikan hasil kosong.');
    }

    return parseResponse(content);
  }

  /// Ubah isi jawaban model (JSON array) menjadi daftar makanan terdeteksi.
  static List<DetectedFood> parseResponse(String raw) {
    final text = _extractJsonArray(raw);
    if (text == null) {
      throw const FoodAiException('Hasil AI tidak dapat dibaca.');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FoodAiException('Hasil AI bukan JSON yang valid.');
    }
    if (decoded is! List) {
      throw const FoodAiException('Hasil AI tidak berbentuk daftar makanan.');
    }

    final catalog = FoodCatalog.isLoaded ? FoodCatalog.instance : null;
    final results = <DetectedFood>[];

    for (final entry in decoded.whereType<Map>()) {
      final map = Map<String, dynamic>.from(entry);
      final name = (map['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;

      final grams = (_toDouble(map['grams']) ?? 100).clamp(1, 3000).toDouble();
      final confidence = (_toDouble(map['confidence']) ?? 0.85).clamp(0.0, 1.0);
      final matched = _matchCatalog(catalog, name);

      final food =
          matched ??
          FoodCatalogItem(
            id: 'ai_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}',
            name: name,
            originalName: name,
            category: _cleanCategory(map['category']),
            source: 'AI Vision 9router',
            energyKcal: _toDouble(map['energyKcal']),
            proteinG: _toDouble(map['proteinG']),
            fatG: _toDouble(map['fatG']),
            carbG: _toDouble(map['carbG']),
            ironMg: _toDouble(map['ironMg']),
            zincMg: _toDouble(map['zincMg']),
          );

      results.add(
        DetectedFood(
          food: food,
          displayName: matched == null ? name : '${matched.name} (AI: $name)',
          grams: grams,
          confidence: confidence,
        ),
      );
    }

    return results;
  }

  /// Ambil potongan `[...]` pertama dari jawaban model, buang code fence.
  static String? _extractJsonArray(String raw) {
    var text = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start < 0 || end <= start) return null;
    text = text.substring(start, end + 1).trim();
    return text.isEmpty ? null : text;
  }

  static const Set<String> _stopWords = {
    'dan',
    'atau',
    'dengan',
    'tanpa',
    'yang',
    'serta',
    'iris',
    'irisan',
    'potong',
    'potongan',
    'campur',
    'campuran',
    'bumbu',
    'kuah',
    'goreng',
    'rebus',
    'kukus',
    'tumis',
    'bakar',
    'panggang',
    'mentah',
    'matang',
    'segar',
    'olahan',
    'sisa',
  };

  static Set<String> _tokens(String value) => value
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((t) => t.length >= 3 && !_stopWords.contains(t))
      .toSet();

  /// Cocokkan nama dari AI dengan entri TKPI agar nilai gizi lebih akurat.
  static FoodCatalogItem? _matchCatalog(FoodCatalog? catalog, String name) {
    if (catalog == null) return null;
    final queryTokens = _tokens(name);
    if (queryTokens.isEmpty) return null;

    FoodCatalogItem? best;
    var bestScore = 0.0;
    for (final item in catalog.foods) {
      final itemTokens = _tokens('${item.name} ${item.originalName}');
      if (itemTokens.isEmpty) continue;
      final overlap = queryTokens.intersection(itemTokens).length;
      if (overlap == 0) continue;
      final score = overlap / queryTokens.length;
      if (score > bestScore) {
        bestScore = score;
        best = item;
      }
    }
    return bestScore >= 0.6 ? best : null;
  }

  static String _cleanCategory(dynamic value) {
    const allowed = {
      'Makanan Pokok',
      'Lauk Hewani',
      'Lauk Nabati',
      'Sayuran',
      'Buah',
      'Minuman',
      'Lainnya',
    };
    final text = value is String ? value.trim() : '';
    for (final category in allowed) {
      if (category.toLowerCase() == text.toLowerCase()) return category;
    }
    return 'Lainnya';
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }
}

class FoodAiException implements Exception {
  const FoodAiException(this.message);

  final String message;

  @override
  String toString() => message;
}
