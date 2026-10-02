import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/child_profile.dart';
import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../services/measurement_service.dart';
import '../services/who_service.dart';
import '../theme/app_colors.dart';
import 'growth_curve_screen.dart';

/// Skrining stunting z-score WHO (F-04/F-05/F-06).
/// Foto hanya indikator tambahan eksperimental (K2), bukan penentu.
class StuntingScreeningScreen extends StatefulWidget {
  final String? initialChildId;
  const StuntingScreeningScreen({super.key, this.initialChildId});

  @override
  State<StuntingScreeningScreen> createState() => _StuntingScreeningScreenState();
}

class _StuntingScreeningScreenState extends State<StuntingScreeningScreen> {
  String? _childId;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _measuredIsLength = true;
  ScreeningResult? _result;
  String? _error;
  bool _disclaimerAccepted = false;
  File? _photo;
  String? _photoMessage;

  String get _userId => AuthService().currentUser?.id ?? 'guest';

  List<ChildProfile> get _children {
    final user = ChildService().getChildren(_userId);
    if (user.isNotEmpty) return user;
    // Kader / demo: tampilkan semua bila milik user kosong.
    if (_userId == 'usr_03') return ChildService().getChildren('usr_03');
    return user;
  }

  @override
  void initState() {
    super.initState();
    _childId = widget.initialChildId;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _hitung() {
    setState(() => _error = null);
    if (!_disclaimerAccepted) {
      setState(() => _error = 'Centang persetujuan skrining dulu (F-01.4).');
      return;
    }
    final child = _children.where((c) => c.id == _childId).firstOrNull;
    if (child == null) {
      setState(() => _error = 'Pilih anak dulu.');
      return;
    }
    final bb = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final tb = double.tryParse(_heightController.text.replaceAll(',', '.'));
    if (bb == null || tb == null) {
      setState(() => _error = 'Isi BB (kg) dan TB/PB (cm) dengan angka.');
      return;
    }
    try {
      final result = WhoService.screen(
        birthDate: child.birthDate,
        measureDate: DateTime.now(),
        isBoy: child.gender == 'L',
        weightKg: bb,
        measuredCm: tb,
        measuredIsLength: _measuredIsLength,
      );
      setState(() => _result = result);
    } catch (e) {
      setState(() => _result = null);
      setState(() => _error = '$e'.replaceFirst('Invalid argument(s): ', ''));
    }
  }

  void _simpan() {
    final child = _children.where((c) => c.id == _childId).firstOrNull;
    final result = _result;
    if (child == null || result == null) return;
    final bb = double.parse(_weightController.text.replaceAll(',', '.'));
    MeasurementService().add(
      childId: child.id,
      date: DateTime.now(),
      weightKg: bb,
      result: result,
    );
    // Sinkron status ringkas ke profil anak.
    ChildService().updateChild(
      child.copyWith(
        weightKg: bb,
        heightCm: result.correctedCm,
        lastCheckDate: DateTime.now(),
        status: result.category == 'Normal'
            ? 'Normal'
            : result.category == 'Pendek'
                ? 'Perlu Pemantauan'
                : 'Risiko Stunting',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengukuran tersimpan ke riwayat.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skrining Stunting',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Penentu utama: z-score WHO TB/U atau PB/U dari input manual. '
            'Foto hanya indikator tambahan eksperimental.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _childId,
            items: _children
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} (${c.ageLabel()})'),
                    ))
                .toList(),
            onChanged: (v) => setState(() {
              _childId = v;
              _result = null;
            }),
            decoration: const InputDecoration(
              labelText: 'Anak',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'BB (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'TB/PB (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Berbaring (PB)')),
              ButtonSegment(value: false, label: Text('Berdiri (TB)')),
            ],
            selected: {_measuredIsLength},
            onSelectionChanged: (s) =>
                setState(() => _measuredIsLength = s.first),
          ),
          const SizedBox(height: 4),
          Text(
            'WHO: <24 bln berbaring, ≥24 bln berdiri. Beda metode dikoreksi ±0,7 cm otomatis.',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _disclaimerAccepted,
            onChanged: (v) => setState(() => _disclaimerAccepted = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Saya memahami hasil hanya skrining awal, bukan diagnosis (wajib).',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
          _photoCard(),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _hitung,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Hitung z-score'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (result != null) ...[
            const SizedBox(height: 16),
            _resultCard(result),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _simpan,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GrowthCurveScreen(childId: _childId!),
                      ),
                    ),
                    icon: const Icon(Icons.show_chart),
                    label: const Text('Kurva'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;
    final check = PhotoIndicatorService.qualityGate(hasImage: true);
    setState(() {
      _photo = File(picked.path);
      _photoMessage = check.message;
    });
  }

  Widget _photoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto anak (opsional, eksperimental)',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${PhotoIndicatorService.experimentalLabel}. Tidak disimpan di server.',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _photo!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(_photo == null ? 'Ambil foto' : 'Ganti foto'),
                ),
              ),
            ],
          ),
          if (_photoMessage != null) ...[
            const SizedBox(height: 6),
            Text(_photoMessage!, style: GoogleFonts.poppins(fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _resultCard(ScreeningResult r) {
    final color = switch (r.category) {
      'Normal' => Colors.green,
      'Pendek' => Colors.orange,
      'Tinggi' => Colors.blue,
      _ => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services_outlined, color: color),
              const SizedBox(width: 8),
              Text(
                r.category,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                'z = ${r.zScore.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Umur saat ukur: ${r.ageMonths} bulan · ${r.isLength ? 'PB' : 'TB'} '
            '${r.correctionApplied ? '(dikoreksi ±0,7 cm)' : ''}\n'
            'Terkoreksi: ${r.correctedCm.toStringAsFixed(1)} cm',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(r.recommendation, style: GoogleFonts.poppins(fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Hasil adalah skrining awal, bukan diagnosis. '
              '${PhotoIndicatorService.experimentalLabel}.',
              style: GoogleFonts.poppins(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
