import 'dart:convert';

import 'package:http/http.dart' as http;

/// Chatbot gizi via Groq API (pretrained Llama, tanpa latih model).
///
/// Pakai: `flutter run --dart-define=GROQ_API_KEY=gsk_...`
/// Tanpa key / offline: fallback bank jawaban lokal (demo tetap jalan).
class ChatMessage {
  final String role; // user | assistant | system
  final String content;
  const ChatMessage({required this.role, required this.content});
}

class ChatbotService {
  static const String model = 'openai/gpt-oss-20b';
  static const String endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  final String apiKey;

  /// Key dibaca dari `--dart-define=GROQ_API_KEY=...` bila tidak diberikan.
  ChatbotService({String? apiKey})
      : apiKey = apiKey ??
            const String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  bool get hasKey => apiKey.isNotEmpty;

  static const _systemPrompt = 'Kamu NURI, asisten gizi Indonesia. '
      'Jawab singkat, bahasa sederhana setara SMP. '
      'Topik: gizi, MPASI, stunting, resep sehat. '
      'Selalu ingatkan hasil hanya edukasi, bukan diagnosis. '
      'Bila di luar topik, arahkan kembali ke gizi anak.';

  /// Kata darurat (E-17). Bila cocok -> arahkan IGD/Puskesmas, jangan
  /// lanjut ke model sebagai jawaban utama.
  static const List<String> emergencyKeywords = [
    'sesak',
    'kejang',
    'tidak sadar',
    'pingsan',
    'muntah terus',
    'diare berdarah',
    'berdarah',
    'demam tinggi',
    'biru',
  ];

  static bool isEmergency(String text) {
    final t = text.toLowerCase();
    return emergencyKeywords.any((k) => t.contains(k));
  }

  static String emergencyReply() =>
      'Terdeteksi kemungkinan DARURAT. Segera ke Puskesmas/IGD terdekat '
      'atau hubungi layanan darurat. Jangan tunggu balasan AI. '
      'Sambil menunggu: jaga jalan napas, catat gejala & waktu kejadian.';

  Future<String> ask(String question, {List<ChatMessage> history = const []}) async {
    if (isEmergency(question)) return emergencyReply();
    if (!hasKey) return _offlineFallback(question);
    try {
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': _systemPrompt},
        for (final h in history.take(8)) {'role': h.role, 'content': h.content},
        {'role': 'user', 'content': question},
      ];
      final res = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model,
              'messages': messages,
              'temperature': 0.4,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 429) {
        return 'Layanan sedang penuh (limit Groq). Coba lagi sebentar. '
            'Sementara: ${_offlineFallback(question)}';
      }
      if (res.statusCode != 200) {
        return 'Gagal menghubungi AI (${res.statusCode}). ${_offlineFallback(question)}';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      final text = choices?.isNotEmpty == true
          ? (choices!.first['message']?['content'] as String? ?? '')
          : '';
      if (text.trim().isEmpty) return _offlineFallback(question);
      return '${text.trim()}\n\n(Catatan: edukasi, bukan diagnosis.)';
    } catch (_) {
      return _offlineFallback(question);
    }
  }

  /// Jawaban lokal bila offline / tanpa key / limit.
  String _offlineFallback(String q) {
    final t = q.toLowerCase();
    if (t.contains('mpasi')) {
      return 'MPASI (6+ bulan): mulai tekstur lembut, protein hewani tiap hari '
          '(telur/ikan/ayam/tempe), lanjutkan ASI. Contoh: bubur nasi + telur + bayam. '
          '(Mode offline — pasang GROQ_API_KEY untuk jawaban AI penuh.)';
    }
    if (t.contains('stunting')) {
      return 'Stunting = gagal tumbuh kronis. Cegah: ASI eksklusif, MPASI bergizi, '
          'pantau kurva WHO tiap bulan, ke posyandu/Puskesmas bila z-score < -2. '
          '(Mode offline.)';
    }
    if (t.contains('resep') || t.contains('menu')) {
      return 'Menu contoh: nasi + ayam + tahu + sayur + buah. Lihat tab MPASI '
          'untuk 5 resep. (Mode offline.)';
    }
    return 'Saya NURI (mode offline: tanpa GROQ_API_KEY). Tanya soal MPASI, '
        'stunting, atau menu sehat. Untuk jawaban AI penuh, pasang key Groq.';
  }
}
