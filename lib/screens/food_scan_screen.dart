import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../data/food_database.dart';
import '../models/child_profile.dart';
import '../services/ai_food_service.dart';
import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../services/food_diary_service.dart';
import '../theme/app_colors.dart';

/// Layar Scan Makanan (FR-01 / F-02).
///
/// Alur: ambil foto (kamera/galeri) -> Analisis (pretrained) ->
/// daftar kandidat + confidence -> koreksi manual bila perlu (F-02.4) ->
/// atur porsi + sesi -> simpan ke Food Diary (F-07).
class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  final _picker = ImagePicker();
  final _ai = AiFoodService();
  final _diary = FoodDiaryService();

  File? _image;
  bool _analyzing = false;
  List<FoodPrediction> _predictions = [];
  FoodItem? _correctedFood;
  final _portionController = TextEditingController(text: '150');
  String _session = 'siang';
  String? _portionError;

  String get _userId => AuthService().currentUser?.id ?? 'guest';
  List<ChildProfile> get _children => ChildService().getChildren(_userId);

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _image = File(picked.path);
        _predictions = [];
        _correctedFood = null;
      });
      await _analyze();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<void> _analyze() async {
    final image = _image;
    if (image == null) return;
    setState(() => _analyzing = true);
    try {
      final results = await _ai.classify(image);
      setState(() {
        _predictions = results;
        final top = results.isNotEmpty ? results.first : null;
        _correctedFood = top?.mappedFood;
        if (_correctedFood != null) {
          _portionController.text =
              _correctedFood!.defaultPortion.toStringAsFixed(0);
        }
      });
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _saveToDiary() {
    final food = _correctedFood;
    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih makanan dulu (koreksi manual).')),
      );
      return;
    }
    final gram = double.tryParse(_portionController.text.trim());
    if (gram == null || gram < 1 || gram > 2000) {
      setState(() => _portionError = 'Porsi 1-2000 gram');
      return;
    }
    final now = DateTime.now();
    final entry = food.toEntry(
      entryId: _diary.generateId(),
      userId: _userId,
      dateKey: FoodDiaryService.dateKey(now),
      session: _session,
      gram: gram,
      childId: _children.isEmpty ? null : _children.first.id,
    );
    _diary.addEntry(now, entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} tersimpan ke diary ($_session).')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Makanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto makanan dianalisis model pretrained (Food-101) lalu dipetakan ke TKPI. Hasil selalu bisa dikoreksi manual.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _image!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.fastfood_outlined, size: 48),
                ),
              ),
            const SizedBox(height: 16),
            if (_analyzing) const Center(child: CircularProgressIndicator()),
            if (!_analyzing && _predictions.isNotEmpty) ...[
              Text(
                'Hasil deteksi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ..._predictions.map(_predictionTile),
              if (_predictions.first.isLowConfidence)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    'Kepercayaan rendah (<50%). Pilih manual dari kandidat atau cari di bawah.',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Koreksi manual (wajib tersedia)',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _manualPicker(),
              const SizedBox(height: 16),
              _portionAndSession(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveToDiary,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan ke Food Diary'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _predictionTile(FoodPrediction p) {
    final mapped = p.mappedFood;
    final selected = _correctedFood?.id == mapped?.id;
    return Card(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${(p.confidence * 100).toStringAsFixed(0)}%'),
        ),
        title: Text(p.label),
        subtitle: Text(
          mapped != null
              ? '-> ${mapped.name} (${mapped.caloriesPer100g.toStringAsFixed(0)} kkal/100g)'
              : 'Tidak ada di TKPI -> pilih manual',
        ),
        trailing: mapped != null
            ? IconButton(
                icon: Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                onPressed: () => setState(() {
                  _correctedFood = mapped;
                  _portionController.text =
                      mapped.defaultPortion.toStringAsFixed(0);
                }),
              )
            : null,
      ),
    );
  }

  Widget _manualPicker() {
    return Autocomplete<FoodItem>(
      optionsBuilder: (value) => FoodDatabase.search(value.text),
      displayStringForOption: (f) => f.name,
      onSelected: (f) => setState(() {
        _correctedFood = f;
        _portionController.text = f.defaultPortion.toStringAsFixed(0);
      }),
      fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
        controller: controller,
        focusNode: focus,
        decoration: InputDecoration(
          hintText: _correctedFood?.name ?? 'Cari nama makanan TKPI...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFFF0F2F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _portionAndSession() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _portionController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Porsi (gram)',
            errorText: _portionError,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _session,
          items: FoodDiaryService.sessions
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(FoodDiaryService.sessionLabel(s)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _session = v ?? 'siang'),
          decoration: const InputDecoration(
            labelText: 'Sesi makan',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
