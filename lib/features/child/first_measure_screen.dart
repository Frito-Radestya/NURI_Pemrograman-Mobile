import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_logo.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/step_dots.dart';
import '../../core/widgets/tiles.dart';
import '../../domain/models/child.dart';
import '../../domain/models/growth_result.dart';
import '../../domain/models/measurement.dart';
import '../../state/app_state.dart';

/// Langkah 2 dari 2: pengukuran awal tumbuh kembang.
class FirstMeasureScreen extends StatefulWidget {
  const FirstMeasureScreen({super.key});

  @override
  State<FirstMeasureScreen> createState() => _FirstMeasureScreenState();
}

class _FirstMeasureScreenState extends State<FirstMeasureScreen> {
  /// 0 = berbaring (telentang), 1 = berdiri tegak.
  int _measureMethod = 1;

  final TextEditingController _weightController =
      TextEditingController(text: '10.4');
  final TextEditingController _heightController =
      TextEditingController(text: '82.5');

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  /// Anak terpilih, atau anak terakhir bila belum ada yang dipilih.
  Child? _resolveChild(NuriAppState state) {
    final Child? selected = state.selectedChild;
    if (selected != null) return selected;
    return state.children.isEmpty ? null : state.children.last;
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/child-data');
    }
  }

  /// Menyimpan pengukuran perdana lalu menuju beranda.
  void _finish() {
    final NuriAppState state = NuriScope.read(context);
    final Child? child = _resolveChild(state);
    if (child == null) {
      context.go('/child-data');
      return;
    }
    final double? weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );
    final double? height = double.tryParse(
      _heightController.text.trim().replaceAll(',', '.'),
    );
    if (weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan angka berat dan panjang/tinggi yang valid.'),
        ),
      );
      return;
    }
    try {
      state.recordMeasurement(
        child: child,
        measuredOn: state.today,
        weightKg: weight,
        lengthHeightCm: height,
        method: _measureMethod == 0
            ? MeasureMethod.berbaring
            : MeasureMethod.berdiri,
      );
      context.go('/home');
    } on GrowthValidationException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.hint == null ? e.message : '${e.message}\n${e.hint}'),
        ),
      );
    } on FormatException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = _resolveChild(state);
    return NuriScaffold(
      topBar: NuriTopBar(
        showBack: true,
        onBack: _back,
        titleWidget: const NuriBrand(markSize: 28),
        actions: [
          NuriAvatar(imageUrl: DemoImages.avatarMother),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                const PillLabel(text: 'Langkah 2 dari 2 • Pengukuran Awal'),
                Text('100% Selesai', style: AppText.caption),
              ],
            ),
            const SizedBox(height: 10),
            const StepProgress(value: 1),
            const SizedBox(height: 20),

            Text('Ukuran Awal Tumbuh Kembang', style: AppText.h1),
            const SizedBox(height: 10),
            Text(
              'Catat data pengukuran terakhir si kecil di Posyandu atau buku '
              'KIA/KMS untuk menetapkan titik awal pemantauan kurva yang sehat.',
              style: AppText.body,
            ),
            const SizedBox(height: 20),

            // Ringkasan anak.
            NuriCard(
              child: Row(
                children: [
                  const IconBadge(
                    icon: Icons.child_care_rounded,
                    color: AppColors.pastelPink,
                    iconColor: Color(0xFFC2636C),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child?.nickname ?? 'Si Kecil',
                          style: AppText.h3,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          child == null
                              ? 'Data anak belum tersedia'
                              : '${child.sex.label} • '
                                  '${child.ageLabelAt(state.today)}',
                          style: AppText.bodySm,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Tag(text: 'UBAH'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            NuriPhoto(
              url: DemoImages.riceFish,
              height: 180,
              overlay: const Positioned(
                left: 16,
                bottom: 16,
                child: PhotoTag(
                  label: 'Buku KIA / Catatan Posyandu Terakhir',
                  icon: Icons.menu_book_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Berat badan.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            Text('Berat Badan Saat Ini', style: AppText.h3),
                      ),
                      const Tag(text: 'Terakhir ditimbang'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _EditableReadout(controller: _weightController, unit: 'kg'),
                  const SizedBox(height: 14),
                  const NoteRow(
                    icon: Icons.monitor_weight_outlined,
                    text:
                        'Bisa merujuk pada timbangan dacin atau digital '
                        'Posyandu bulan ini.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Panjang / tinggi badan.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Panjang / Tinggi Badan',
                            style: AppText.h3),
                      ),
                      const Tag(text: 'Standar WHO'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _EditableReadout(controller: _heightController, unit: 'cm'),
                  const SizedBox(height: 16),
                  Text('CARA MENGUKUR TERAKHIR:', style: AppText.label),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ChoicePill(
                          label: 'Berbaring (Telentang)',
                          selected: _measureMethod == 0,
                          onTap: () => setState(() => _measureMethod = 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ChoicePill(
                          label: 'Berdiri Tegak',
                          selected: _measureMethod == 1,
                          onTap: () => setState(() => _measureMethod = 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _ItalicNote(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Untuk balita di atas usia 12 bulan yang sudah bisa '
                        'mandiri berdiri, pengukuran tegak sangat dianjurkan.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lingkar kepala.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Lingkar Kepala', style: AppText.h3),
                      ),
                      const Tag(
                        text: 'Opsional',
                        color: AppColors.pastelPink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _Readout(
                    value: '46.0',
                    unit: 'cm',
                    color: AppColors.inkFaint,
                  ),
                  const SizedBox(height: 14),
                  const NoteRow(
                    icon: Icons.auto_awesome,
                    text:
                        'Membantu pemantauan perkembangan otak dan lingkup '
                        'kepala ideal si kecil.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            NoteBox(
              background: AppColors.surfaceSand,
              icon: Icons.eco_rounded,
              child: RichText(
                text: const TextSpan(
                  style: AppText.bodySm,
                  children: [
                    TextSpan(
                      text: 'NURI Menemani Tanpa Menghakimi',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    TextSpan(
                      text:
                          '\nAngka ini hanyalah titik awal kompas kita. NURI '
                          'tidak memberi cap atau label pada balita, melainkan '
                          'membantu Bunda menyusun variasi menu kaya protein '
                          'hewani dan gizi seimbang yang menyenangkan di meja '
                          'makan.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            NuriPrimaryButton(
              label: 'Selesaikan & Buat Profil Si Kecil',
              trailingArrow: true,
              onPressed: _finish,
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Saya akan isi pengukuran nanti',
                  style: AppText.bodyStrong.copyWith(
                    color: AppColors.brandText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Kotak tampilan angka besar bergaya kolom input.
class _Readout extends StatelessWidget {
  const _Readout({
    required this.value,
    required this.unit,
    this.color = AppColors.ink,
  });

  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: AppText.metric.copyWith(fontSize: 34, color: color),
            ),
            TextSpan(
              text: '  $unit',
              style: AppText.bodyStrong.copyWith(
                color: AppColors.inkSoft,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kolom isian angka besar yang bisa diedit (berat/panjang badan).
class _EditableReadout extends StatelessWidget {
  const _EditableReadout({required this.controller, required this.unit});

  final TextEditingController controller;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppText.metric.copyWith(
                fontSize: 34,
                color: AppColors.ink,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Text(
            '  $unit',
            style: AppText.bodyStrong.copyWith(
              color: AppColors.inkSoft,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand : AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.bodyStrong.copyWith(
              color: selected ? Colors.white : AppColors.ink,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItalicNote extends StatelessWidget {
  const _ItalicNote({required this.text, this.icon = Icons.info_outline_rounded});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.inkSoft),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppText.bodySm.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}
