import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../data/nuri_repository.dart' show ScreeningRecord;
import '../../domain/models/child.dart';
import '../../domain/models/growth_result.dart';
import '../../domain/models/growth_status.dart';
import '../../domain/models/measurement.dart';
import '../../state/app_state.dart';

/// Input pengukuran antropometri & skrining klinis untuk satu balita.
class KaderEntryScreen extends StatefulWidget {
  const KaderEntryScreen({super.key});

  @override
  State<KaderEntryScreen> createState() => _KaderEntryScreenState();
}

class _KaderEntryScreenState extends State<KaderEntryScreen> {
  static const double _defaultWeight = 9.10;
  static const double _defaultHeight = 80.2;

  String? _childId;
  double _weight = _defaultWeight;
  double _height = _defaultHeight;
  MeasureMethod _method = MeasureMethod.berdiri;
  bool _initialized = false;

  double _lila = 12.8;
  double _lika = 46.5;
  int _lilaBand = 2; // 0 merah, 1 kuning, 2 hijau
  int _edema = 0; // 0 tidak ada, 1 ada

  final Set<String> _sickness = {'Tidak Ada Sakit'};
  bool _vitA = true;
  bool _deworm = true;

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    _childId = child?.id;
    _applyBaseline(state, _childId);
  }

  void _applyBaseline(NuriAppState state, String? childId) {
    if (childId == null) {
      _weight = _defaultWeight;
      _height = _defaultHeight;
      _method = MeasureMethod.berdiri;
      return;
    }
    final ScreeningRecord? latest = state.latestScreening(childId);
    if (latest == null) {
      _weight = _defaultWeight;
      _height = _defaultHeight;
      _method = MeasureMethod.berdiri;
      return;
    }
    _weight = latest.measurement.weightKg;
    _height = latest.measurement.lengthHeightCm;
    _method = latest.measurement.method;
  }

  Child? _selectedChild(NuriAppState state) {
    if (state.children.isEmpty) return null;
    for (final Child child in state.children) {
      if (child.id == _childId) return child;
    }
    return state.children.first;
  }

  void _selectChild(NuriAppState state, Child child) {
    setState(() {
      _childId = child.id;
      state.selectChild(child.id);
      _applyBaseline(state, child.id);
    });
  }

  void _submit() {
    final NuriAppState state = NuriScope.read(context);
    final Child? child = _selectedChild(state);
    if (child == null) {
      _snack('Belum ada balita yang dipilih.');
      return;
    }
    try {
      state.recordMeasurement(
        child: child,
        measuredOn: state.today,
        weightKg: _weight,
        lengthHeightCm: _height,
        method: _method,
        sessionId: state.activeSession?.id,
      );
      context.go('/kader-result');
    } on GrowthValidationException catch (e) {
      _snack(
        e.hint == null ? e.message : '${e.message} ${e.hint}',
      );
    } catch (e) {
      _snack('Gagal menyimpan pengukuran: $e');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = _selectedChild(state);
    final ScreeningRecord? latest =
        child == null ? null : state.latestScreening(child.id);

    if (state.children.isEmpty) {
      return NuriScaffold(
        topBar: NuriTopBar(
          onBack: () =>
              context.canPop() ? context.pop() : context.go('/kader'),
          titleWidget: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('NURI KADER', style: AppText.caption),
              SizedBox(height: 2),
              Text('Input Pengukuran', style: AppText.h3),
            ],
          ),
        ),
        body: const Center(
          child: NoteBox(
            background: AppColors.pastelPeach,
            icon: Icons.info_outline_rounded,
            child: Text(
              'Belum ada data balita. Tambahkan anak terlebih dahulu sebelum '
              'melakukan pengukuran.',
              style: AppText.bodySm,
            ),
          ),
        ),
      );
    }

    return NuriScaffold(
      topBar: NuriTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/kader'),
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${child!.nickname} • ${child.ageLabelAt(state.today)}',
              style: AppText.caption,
            ),
            const SizedBox(height: 2),
            const Text('Input Pengukuran & Skrining', style: AppText.h3),
          ],
        ),
        actions: [
          NuriSoftButton(icon: Icons.help_outline_rounded, onPressed: () {}),
          const SizedBox(width: 8),
          NuriAvatar(initials: _initials(state.user?.displayName ?? 'K'), size: 44),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: PillLabel(text: 'Meja 2 • Antropometri Cepat'),
              ),
              Text('Langkah 1 dari 2', style: AppText.caption),
            ],
          ),
          const SizedBox(height: 14),

          // Pilih balita.
          if (state.children.length > 1) ...[
            const Text('Pilih Balita', style: AppText.h3),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final Child option in state.children)
                  _SelectPill(
                    label: option.nickname,
                    selected: option.id == child.id,
                    fill: false,
                    onTap: () => _selectChild(state, option),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Identitas balita.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NuriAvatar(
                      initials: _initials(child.nickname),
                      size: 52,
                      background: AppColors.pastelPink,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(child.nickname, style: AppText.h3),
                          const SizedBox(height: 3),
                          Text(
                            '${child.ageLabelAt(state.today)} • '
                            '${child.sex.label}',
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.inkFaint,
                    ),
                  ],
                ),
                const Divider(height: 28, color: AppColors.line),
                Text(
                  latest == null
                      ? 'BELUM ADA PENGUKURAN SEBELUMNYA'
                      : 'BASELINE TERAKHIR  •  '
                          '${_formatDate(latest.measurement.measuredOn)}',
                  style: AppText.label,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        value: latest == null
                            ? '${_fmt(_defaultWeight)} kg'
                            : '${_fmt(latest.measurement.weightKg)} kg',
                        label: 'Berat',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        value: latest == null
                            ? '${_fmt(_defaultHeight)} cm'
                            : '${_fmt(latest.measurement.lengthHeightCm)} cm',
                        label: 'Tinggi',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        value: latest == null
                            ? '-'
                            : '${latest.result.zLabel} SD',
                        label: 'Z-Score',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: const [
              Expanded(
                child: Text('Antropometri Wajib', style: AppText.h3),
              ),
              Text('Tahap 2: Skrining Klinis', style: AppText.caption),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Berat badan.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Berat Badan (BB) *Wajib', style: AppText.h3),
                const SizedBox(height: 4),
                const Text(
                  'Timbangan digital terkalibrasi posyandu',
                  style: AppText.caption,
                ),
                const SizedBox(height: 16),
                _Stepper(
                  text: '${_fmt(_weight)} kg',
                  onMinus: () => setState(() {
                    _weight = (_weight - 0.05).clamp(2.0, 30.0);
                  }),
                  onPlus: () => setState(() {
                    _weight = (_weight + 0.05).clamp(2.0, 30.0);
                  }),
                ),
                if (latest != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _weightDeltaLabel(latest.measurement.weightKg),
                          style: AppText.caption,
                        ),
                      ),
                      const Text('Target: +0.20 kg', style: AppText.caption),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Tinggi badan.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2. Tinggi Badan (TB/PB) *Wajib', style: AppText.h3),
                const SizedBox(height: 4),
                const Text(
                  'Stadiometer / Infantometer standar Kemenkes',
                  style: AppText.caption,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SelectPill(
                        label: 'Berdiri (TB)',
                        selected: _method == MeasureMethod.berdiri,
                        onTap: () => setState(
                          () => _method = MeasureMethod.berdiri,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SelectPill(
                        label: 'Terlentang (PB)',
                        selected: _method == MeasureMethod.berbaring,
                        onTap: () => setState(
                          () => _method = MeasureMethod.berbaring,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Stepper(
                  text: '${_fmt(_height)} cm',
                  onMinus: () => setState(() {
                    _height = (_height - 0.1).clamp(45.0, 120.0);
                  }),
                  onPlus: () => setState(() {
                    _height = (_height + 0.1).clamp(45.0, 120.0);
                  }),
                ),
                if (latest != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 16,
                        color: AppColors.statusNormal,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _heightDeltaLabel(latest.measurement.lengthHeightCm),
                          style: AppText.caption,
                        ),
                      ),
                      StatusChip(
                        text: latest.result.status.label,
                        color: _statusSoft(latest.result.status),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. LiLA.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '3. Lingkar Lengan Atas (LiLA) *Gizi Akut',
                  style: AppText.h3,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gunakan pita LiLA pada lengan kiri anak',
                  style: AppText.caption,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SelectPill(
                      label: '13.5 Merah',
                      selected: _lilaBand == 0,
                      fill: false,
                      onTap: () => setState(() => _lilaBand = 0),
                    ),
                    _SelectPill(
                      label: '11.5 – 12.5 Kuning',
                      selected: _lilaBand == 1,
                      fill: false,
                      onTap: () => setState(() => _lilaBand = 1),
                    ),
                    _SelectPill(
                      label: '12.5 Hijau ✓',
                      selected: _lilaBand == 2,
                      fill: false,
                      onTap: () => setState(() => _lilaBand = 2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Stepper(
                  text: '${_fmt(_lila)} cm',
                  onMinus: () => setState(() {
                    _lila = (_lila - 0.1).clamp(8.0, 20.0);
                  }),
                  onPlus: () => setState(() {
                    _lila = (_lila + 0.1).clamp(8.0, 20.0);
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. LiKA.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        '4. Lingkar Kepala (LiKA)',
                        style: AppText.h3,
                      ),
                    ),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.inkFaint,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Stepper(
                  text: '${_fmt(_lika)} cm',
                  onMinus: () => setState(() {
                    _lika = (_lika - 0.1).clamp(28.0, 60.0);
                  }),
                  onPlus: () => setState(() {
                    _lika = (_lika + 0.1).clamp(28.0, 60.0);
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SectionHeader(
            title: 'Skrining Klinis & Suplemen',
            actionLabel: 'Ketuk Sekali',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edema Bilateral (Bengkak Punggung Kaki / Tangan)',
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SelectPill(
                        label: 'Tidak Ada (Normal)',
                        selected: _edema == 0,
                        onTap: () => setState(() => _edema = 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SelectPill(
                        label: 'Ada (Bengkak)',
                        selected: _edema == 1,
                        onTap: () => setState(() => _edema = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Riwayat Sakit 1 Bulan Terakhir',
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _selectChip('Batuk Pilek (ISPA)'),
                    _selectChip('Diare'),
                    _selectChip('Demam Tinggi'),
                    _selectChip('Tidak Ada Sakit'),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Suplementasi & Profilaksis',
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: 8),
                _CheckRow(
                  title: 'Vitamin A Kapsul Merah (200.000 IU)',
                  subtitle: 'Terakhir diberikan pada kunjungan sebelumnya',
                  value: _vitA,
                  onChanged: (v) => setState(() => _vitA = v),
                ),
                _CheckRow(
                  title: 'Obat Cacing (Albendazole)',
                  subtitle: 'Diberikan H-1 oleh Posyandu',
                  value: _deworm,
                  onChanged: (v) => setState(() => _deworm = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const NoteBox(
            background: AppColors.pastelGreenSoft,
            icon: Icons.verified_outlined,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Entri Sesuai PRD NURI',
                    style: AppText.bodyStrong,
                  ),
                  TextSpan(
                    text:
                        '\nBB & TB akan dihitung z-score-nya secara lokal '
                        '(WHO) dan disimpan sebagai riwayat baru.',
                    style: AppText.bodySm,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Draf',
                  icon: Icons.save_outlined,
                  filled: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NuriPrimaryButton(
                  label: 'Lanjut ke Evaluasi Gizi',
                  onPressed: _submit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Kader: ${state.user?.displayName ?? 'Kader'} • '
              '${state.user?.posyanduName ?? 'Posyandu Melati'}',
              style: AppText.caption,
            ),
          ),
        ],
      ),
    );
  }

  String _weightDeltaLabel(double previous) {
    final double delta = _weight - previous;
    final String sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(2)} kg vs pengukuran lalu';
  }

  String _heightDeltaLabel(double previous) {
    final double delta = _height - previous;
    final String sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(1)} cm dari pengukuran lalu';
  }

  Widget _selectChip(String label) {
    final bool selected = _sickness.contains(label);
    return _SelectPill(
      label: label,
      selected: selected,
      fill: false,
      onTap: () => setState(() {
        if (selected) {
          _sickness.remove(label);
        } else {
          _sickness.add(label);
        }
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian lokal.
// ---------------------------------------------------------------------------

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.title.copyWith(fontSize: 14.5)),
        const SizedBox(height: 2),
        Text(label, style: AppText.caption),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.text,
    required this.onMinus,
    required this.onPlus,
  });

  final String text;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NuriSoftButton(
          icon: Icons.remove_rounded,
          size: 46,
          background: AppColors.surfaceSoft,
          onPressed: onMinus,
        ),
        Expanded(
          child: Center(
            child: Text(text, style: AppText.h2),
          ),
        ),
        NuriSoftButton(
          icon: Icons.add_rounded,
          size: 46,
          background: AppColors.surfaceSoft,
          onPressed: onPlus,
        ),
      ],
    );
  }
}

class _SelectPill extends StatelessWidget {
  const _SelectPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.fill = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: fill ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.line,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.bodySm.copyWith(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: value ? AppColors.brand : AppColors.surface,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: value ? AppColors.brand : AppColors.lineStrong,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.bodyStrong),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utilitas.
// ---------------------------------------------------------------------------

String _initials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

Color _statusSoft(GrowthStatus status) {
  switch (status) {
    case GrowthStatus.normal:
      return AppColors.statusNormalSoft;
    case GrowthStatus.pendek:
      return AppColors.statusPendekSoft;
    case GrowthStatus.sangatPendek:
      return AppColors.statusSangatPendekSoft;
    case GrowthStatus.tinggi:
      return AppColors.statusTinggiSoft;
  }
}

const List<String> _bulan = <String>[
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

String _formatDate(DateTime date) =>
    '${date.day} ${_bulan[date.month - 1]} ${date.year}';
