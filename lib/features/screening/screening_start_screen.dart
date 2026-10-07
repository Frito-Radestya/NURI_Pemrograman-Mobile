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
import '../../data/nuri_repository.dart';
import '../../domain/models/child.dart';
import '../../domain/models/growth_result.dart';
import '../../domain/models/measurement.dart';
import '../../state/app_state.dart';

/// Langkah 1 dari 2: input ukuran & pola tumbuh untuk skrining.
class ScreeningStartScreen extends StatefulWidget {
  const ScreeningStartScreen({super.key});

  @override
  State<ScreeningStartScreen> createState() => _ScreeningStartScreenState();
}

class _ScreeningStartScreenState extends State<ScreeningStartScreen> {
  static const double _defaultWeight = 10.4;
  static const double _defaultHeight = 82.5;

  double _weight = _defaultWeight;
  double _height = _defaultHeight;
  MeasureMethod _method = MeasureMethod.berbaring;

  bool _initialized = false;
  bool _active = true;
  bool _appetite = true;
  bool _sick = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final NuriAppState state = NuriScope.read(context);
    final Child? child = state.selectedChild;
    if (child != null) _applyChild(state, child);
  }

  /// Mengisi stepper dari pengukuran terakhir dan metode dianjurkan WHO.
  void _applyChild(NuriAppState state, Child child) {
    final ScreeningRecord? latest = state.latestScreening(child.id);
    _weight = latest?.measurement.weightKg ?? _defaultWeight;
    _height = latest?.measurement.lengthHeightCm ?? _defaultHeight;
    _method = MeasureMethod.recommendedFor(child.ageInMonthsAt(state.today));
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _changeChild() async {
    final NuriAppState state = NuriScope.read(context);
    if (state.children.length <= 1) {
      context.go('/child-data');
      return;
    }
    final Child? picked = await showModalBottomSheet<Child>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Pilih anak', style: AppText.h3),
              ),
              for (final Child option in state.children)
                ListTile(
                  leading:
                      const NuriAvatar(imageUrl: DemoImages.avatarChild),
                  title: Text(option.nickname, style: AppText.title),
                  subtitle: Text(
                    option.ageLabelAt(state.today),
                    style: AppText.caption,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked == null) return;
    state.selectChild(picked.id);
    if (!mounted) return;
    setState(() => _applyChild(state, picked));
  }

  /// Menyimpan pengukuran lalu membuka hasil; error ditampilkan via SnackBar.
  void _submit() {
    final NuriAppState state = NuriScope.read(context);
    final Child? child = state.selectedChild;
    if (child == null) {
      context.go('/child-data');
      return;
    }
    try {
      state.recordMeasurement(
        child: child,
        measuredOn: state.today,
        weightKg: _weight,
        lengthHeightCm: _height,
        method: _method,
      );
      context.go('/screening-result');
    } on GrowthValidationException catch (error) {
      if (!mounted) return;
      final String message = error.hint == null
          ? error.message
          : '${error.message}\n${error.hint}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    final DateTime now = DateTime.now();
    final ScreeningRecord? latest =
        child == null ? null : state.latestScreening(child.id);

    return NuriScaffold(
      topBar: NuriTopBar(
        showBack: true,
        onBack: _back,
        titleWidget: const NuriBrand(markSize: 26),
        actions: [
          NuriSoftButton(icon: Icons.help_outline, onPressed: () {}),
          const SizedBox(width: 8),
          NuriAvatar(imageUrl: DemoImages.avatarMother),
        ],
      ),
      body: child == null
          ? const _NoChildState()
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PillLabel(text: 'Langkah 1 dari 2'),
                const Spacer(),
                Text('50% Lengkap', style: AppText.caption),
              ],
            ),
            const SizedBox(height: 10),
            const StepProgress(value: 0.5),
            const SizedBox(height: 8),
            Text('Data Ukuran & Pola Tumbuh Terkini', style: AppText.caption),
            const SizedBox(height: 20),

            // Kartu edukasi.
            NuriCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBadge(icon: Icons.volunteer_activism_outlined),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Skrining Dini, Bukan Diagnosis Medis',
                            style: AppText.h3),
                        const SizedBox(height: 6),
                        Text(
                          'Skrining ini bertujuan mendeteksi tren pertumbuhan '
                          'si kecil untuk rekomendasi nutrisi harian dan '
                          'pendampingan Posyandu/Bidan, bukan vonis medis.',
                          style: AppText.body.copyWith(fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu profil anak.
            NuriCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const NuriAvatar(
                        imageUrl: DemoImages.avatarChild,
                        size: 52,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(child.nickname, style: AppText.h3),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Flexible(
                                  child: Tag(text: child.ageLabelAt(now)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    child.sex.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.caption,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      NuriSoftButton(
                        icon: Icons.swap_horiz_rounded,
                        size: 40,
                        onPressed: _changeChild,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.line, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Catatan Terakhir Posyandu',
                                style: AppText.caption),
                            const SizedBox(height: 4),
                            Text(
                              latest == null
                                  ? 'Belum ada catatan'
                                  : '${_fmtDate(latest.measurement.measuredOn)}'
                                        ' • ${child.posyanduName ?? 'Posyandu'}',
                              style:
                                  AppText.bodyStrong.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _MiniStat(
                        value: latest == null
                            ? '—'
                            : '${_fmtNum(latest.measurement.weightKg)} kg',
                        label: 'Berat',
                      ),
                      const SizedBox(width: 8),
                      _MiniStat(
                        value: latest == null
                            ? '—'
                            : '${_fmtNum(latest.measurement.lengthHeightCm)} cm',
                        label: 'Tinggi',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Berat badan terkini.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    title: 'Berat Badan Terkini',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pantau kenaikan berat badan terhadap baku WHO MGRS',
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 16),
                  _Stepper(
                    value: '${_fmtNum(_weight)} kg',
                    onMinus: () => setState(() {
                      _weight = (_weight - 0.1).clamp(2.0, 30.0);
                    }),
                    onPlus: () => setState(() {
                      _weight = (_weight + 0.1).clamp(2.0, 30.0);
                    }),
                  ),
                  const SizedBox(height: 14),
                  NoteRow(
                    icon: Icons.schedule,
                    text: 'Isi sesuai hasil timbangan terbaru. Usia '
                        '${child.ageLabelAt(now)}.',
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
                  _CardHeader(
                    title: 'Panjang / Tinggi Badan',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Indikator utama laju pertumbuhan linear tinggi badan',
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ChoicePill(
                          label: 'Berbaring (<24 bln)',
                          selected: _method == MeasureMethod.berbaring,
                          onTap: () => setState(
                              () => _method = MeasureMethod.berbaring),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ChoicePill(
                          label: 'Berdiri Tegak',
                          selected: _method == MeasureMethod.berdiri,
                          onTap: () => setState(
                              () => _method = MeasureMethod.berdiri),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Stepper(
                    value: '${_fmtNum(_height)} cm',
                    onMinus: () => setState(() {
                      _height = (_height - 0.1).clamp(30.0, 140.0);
                    }),
                    onPlus: () => setState(() {
                      _height = (_height + 0.1).clamp(30.0, 140.0);
                    }),
                  ),
                  const SizedBox(height: 14),
                  NoteRow(
                    icon: Icons.insights_rounded,
                    text: 'WHO median TB/U usia ${child.ageLabelAt(now)}: '
                        '${_fmtNum(_medianCm(state, child))} cm',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ukuran tambahan.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Ukuran Tambahan', style: AppText.h3),
                      ),
                      const Tag(
                        text: 'Opsional',
                        color: AppColors.pastelPeach,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: _MetricField(
                          label: 'LILA (Lengan Atas)',
                          value: '14.5',
                          unit: 'cm',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _MetricField(
                          label: 'Lingkar Kepala',
                          value: '47.0',
                          unit: 'cm',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kondisi & perilaku.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kondisi & Perilaku 2 Minggu Terakhir',
                      style: AppText.h3),
                  const SizedBox(height: 6),
                  Text(
                    'Membantu dokter dan kader memahami konteks fisik si kecil',
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 14),
                  _CheckRow(
                    title: 'Anak lincah & aktif bermain',
                    subtitle: 'Tidak lemas atau pasif berlebihan',
                    icon: Icons.directions_run_rounded,
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  const SizedBox(height: 10),
                  _CheckRow(
                    title: 'Nafsu makan dan minum baik',
                    subtitle: 'Menghabiskan porsi tanpa gerakan tutup mulut',
                    icon: Icons.restaurant_rounded,
                    value: _appetite,
                    onChanged: (v) => setState(() => _appetite = v),
                  ),
                  const SizedBox(height: 10),
                  _CheckRow(
                    title: 'Demam, batuk pilek, atau diare',
                    subtitle: 'Sempat terjadwal dalam 14 hari terakhir',
                    icon: Icons.sick_outlined,
                    value: _sick,
                    onChanged: (v) => setState(() => _sick = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu fitur AI.
            NuriCard(
              color: AppColors.pastelPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: PillLabel(
                          text: 'Fitur Pintar NURI',
                          color: AppColors.surface,
                          textColor: AppColors.brand,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Tag(
                        text: 'Tingkat Akurasi +40%',
                        color: AppColors.surface,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Pemeriksaan Visual Berbantuan AI NURI',
                      style: AppText.h3),
                  const SizedBox(height: 6),
                  Text(
                    'Ambil foto postur si kecil (tampak depan saat tegak atau '
                    'berbaring) untuk validasi proporsi tinggi dan kurva tumbuh '
                    'kembang yang lebih akurat.',
                    style: AppText.body.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: NoteRow(
                          icon: Icons.lock_outline_rounded,
                          text: 'Enkripsi medis & privat',
                          color: AppColors.inkSoft,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: NoteRow(
                          icon: Icons.bolt_rounded,
                          text: 'Hanya butuh 10 detik',
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  NuriPhoto(
                    url: DemoImages.measuredChild,
                    height: 150,
                    overlay: const Positioned(
                      left: 12,
                      bottom: 12,
                      child: PhotoTag(
                        label: 'Foto dipandu dengan panduan otomatis',
                        icon: Icons.center_focus_strong_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  NuriSecondaryButton(
                    label: 'Ambil Foto Si Kecil Sekarang',
                    icon: Icons.camera_alt_outlined,
                    filled: true,
                    onPressed: () => context.go('/camera-posture'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            NuriPrimaryButton(
              label: 'Lanjut ke Kuesioner Asupan Gizi',
              trailingArrow: true,
              onPressed: _submit,
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Simpan Draf Skrining',
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

/// Keadaan kosong saat belum ada anak terdaftar.
class _NoChildState extends StatelessWidget {
  const _NoChildState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        NuriCard(
          child: Column(
            children: [
              const IconBadge(
                icon: Icons.child_care_rounded,
                size: 60,
                radius: 20,
              ),
              const SizedBox(height: 14),
              const Text('Belum Ada Data Anak', style: AppText.h3),
              const SizedBox(height: 8),
              const Text(
                'Tambahkan profil anak sebelum melakukan pengukuran.',
                style: AppText.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              NuriPrimaryButton(
                label: 'Tambah anak',
                icon: Icons.add_rounded,
                onPressed: () => context.go('/child-data'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper format & referensi WHO.

const List<String> _idMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _fmtDate(DateTime date) =>
    '${date.day} ${_idMonths[date.month - 1]} ${date.year}';

String _fmtNum(double value, {int digits = 1}) =>
    value.toStringAsFixed(digits).replaceAll('.', ',');

/// Median tinggi/panjang badan WHO pada umur anak saat ini.
double _medianCm(NuriAppState state, Child child) => state.reference.whoLms
    .valueForZ(child.sex, child.ageInMonthsAt(state.today).clamp(0, 60).toInt(), 0);

// ---------------------------------------------------------------------------

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.h3)),
        if (icon != null) Icon(icon, size: 18, color: AppColors.inkFaint),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(value, style: AppText.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 1),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _StepButton(icon: Icons.remove_rounded, onTap: onMinus),
          Expanded(
            child: Center(
              child: Text(value, style: AppText.metric.copyWith(fontSize: 28)),
            ),
          ),
          _StepButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: AppColors.brand, size: 22),
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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

class _MetricField extends StatelessWidget {
  const _MetricField({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppText.h3.copyWith(fontSize: 18),
                ),
                TextSpan(
                  text: ' $unit',
                  style: AppText.caption.copyWith(color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? AppColors.pastelGreenSoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: value ? AppColors.brand : AppColors.line,
          width: value ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          IconBadge(
            icon: icon,
            size: 40,
            radius: 12,
            color: value ? AppColors.pastelGreen : AppColors.surface,
            iconColor: value ? AppColors.brand : AppColors.inkSoft,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.bodyStrong.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.brand,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
