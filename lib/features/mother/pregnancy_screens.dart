import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class TtdScreen extends ConsumerWidget {
  const TtdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Tablet Tambah Darah',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(title: 'Tidak ada kehamilan aktif'),
              ),
            ],
          ),
        ),
      );
    }

    final today = dateOnly(DateTime.now());
    final takenToday = pregnancy.ttdDates.contains(dateToIso(today));
    final count = pregnancy.ttdCount;
    final progress = (count / AkgReference.ttdTarget).clamp(0.0, 1.0);
    final remaining = AkgReference.ttdTarget - count;
    final start = today.subtract(Duration(days: today.weekday - 1 + 21));
    final dates = List.generate(
      28,
      (index) => start.add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Tablet Tambah Darah',
              subtitle: 'Target ${AkgReference.ttdTarget} tablet selama hamil',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF145C45), Color(0xFF0E4332)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF145C45).withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Pill(
                                label: 'TTD harian',
                                icon: Icons.medication_rounded,
                                background: AppColors.softMint,
                                foreground: AppColors.deepForest,
                                fontSize: 11.5,
                                bold: true,
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.leafGreen,
                                size: 22,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$count',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 42,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 5,
                                  left: 3,
                                ),
                                child: Text(
                                  '/ ${AkgReference.ttdTarget} tablet',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.86),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => Stack(
                                children: [
                                  Container(
                                    height: 7,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 7,
                                      color: AppColors.leafGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            remaining <= 0
                                ? 'Semua tablet tercatat. Teruskan pola makan bergizi.'
                                : '$remaining tablet lagi menuju target. Minum satu setiap hari.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      color: takenToday ? AppColors.mint : AppColors.surface,
                      borderColor: takenToday
                          ? AppColors.mintStrong
                          : AppColors.line,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: takenToday
                                  ? AppColors.primary
                                  : AppColors.peachSoft,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              takenToday
                                  ? Icons.check_rounded
                                  : Icons.medication_rounded,
                              color: takenToday
                                  ? Colors.white
                                  : AppColors.coral,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  takenToday
                                      ? 'TTD hari ini sudah dicatat'
                                      : 'Sudah minum TTD hari ini?',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatDateId(today),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(appControllerProvider.notifier)
                                  .toggleTtdForDate(today);
                            },
                            child: Text(
                              takenToday ? 'Batalkan' : 'Catat',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: takenToday
                                    ? AppColors.muted
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SectionHeader(
                      title: '4 minggu terakhir',
                      subtitle: 'Ketuk tanggal untuk menandai.',
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children:
                                [
                                      'Sen',
                                      'Sel',
                                      'Rab',
                                      'Kam',
                                      'Jum',
                                      'Sab',
                                      'Min',
                                    ]
                                    .map(
                                      (day) => Expanded(
                                        child: Center(
                                          child: Text(
                                            day,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.muted,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dates.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 6,
                                  crossAxisSpacing: 6,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) {
                              final date = dates[index];
                              final isFuture = date.isAfter(today);
                              final taken = pregnancy.ttdDates.contains(
                                dateToIso(date),
                              );
                              final isToday =
                                  dateToIso(date) == dateToIso(today);
                              return InkWell(
                                onTap: isFuture
                                    ? null
                                    : () {
                                        HapticFeedback.selectionClick();
                                        ref
                                            .read(
                                              appControllerProvider.notifier,
                                            )
                                            .toggleTtdForDate(date);
                                      },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: taken
                                        ? AppColors.primary
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isToday
                                          ? AppColors.coral
                                          : taken
                                          ? AppColors.primary
                                          : AppColors.line,
                                      width: isToday ? 1.6 : 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isFuture
                                              ? AppColors.line
                                              : taken
                                              ? Colors.white
                                              : AppColors.text,
                                        ),
                                      ),
                                      if (taken)
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _CalendarLegend(
                                color: AppColors.primary,
                                label: 'Sudah minum',
                              ),
                              SizedBox(width: 16),
                              _CalendarLegend(
                                color: AppColors.background,
                                label: 'Belum',
                                border: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const InfoBanner(
                      title: 'Cara minum yang nyaman',
                      body: 'Minum setelah makan atau sebelum tidur bila mual. Hindari teh dan kopi berdekatan karena menghambat penyerapan zat besi.',
                      icon: Icons.lightbulb_outline_rounded,
                    ),
                    const SizedBox(height: 10),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({
    required this.color,
    required this.label,
    this.border = false,
  });

  final Color color;
  final String label;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border ? Border.all(color: AppColors.line) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
      ],
    );
  }
}

class AncScreen extends ConsumerWidget {
  const AncScreen({super.key});

  static const _schedule = [
    (
      'ANC 1 (Trimester 1)',
      'Sebelum 12 minggu',
      'Pemeriksaan Dokter & Skrining USG 1 (konfirmasi kantung & DJJ)',
    ),
    (
      'ANC 2 (Trimester 2)',
      '12–20 minggu',
      'Pemeriksaan Bidan/Dokter: pemantauan tumbuh janin & imunisasi TT',
    ),
    (
      'ANC 3 (Trimester 2)',
      '20–26 minggu',
      'Pemeriksaan Bidan: skrining preeklampsia, LiLA, Hb',
    ),
    (
      'ANC 4 (Trimester 3)',
      '26–32 minggu',
      'Pemeriksaan Bidan: posisi janin, denyut jantung, keluhan',
    ),
    (
      'ANC 5 (Trimester 3)',
      '32–36 minggu',
      'Pemeriksaan Dokter & Skrining USG 2 (letak plasenta, ketuban, taksiran BB janin)',
    ),
    (
      'ANC 6 (Trimester 3)',
      '36–40 minggu',
      'Pemeriksaan akhir kesiapan persalinan aman & inisiasi menyusu dini',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Kunjungan ANC',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(title: 'Tidak ada kehamilan aktif'),
              ),
            ],
          ),
        ),
      );
    }
    final visits = List<AncVisit>.from(pregnancy.ancVisits)
      ..sort((a, b) => a.date.compareTo(b.date));
    final progress = (visits.length / AkgReference.ancTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Kunjungan ANC',
              subtitle: 'Minimal ${AkgReference.ancTarget} kali selama hamil',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF145C45), Color(0xFF0E4332)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF145C45).withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Pill(
                                label: 'Antenatal Care',
                                icon: Icons.event_available_rounded,
                                background: AppColors.softMint,
                                foreground: AppColors.deepForest,
                                fontSize: 11.5,
                                bold: true,
                              ),
                              const Spacer(),
                              Text(
                                '${visits.length} / ${AkgReference.ancTarget}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) => Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      height: 8,
                                      color: AppColors.leafGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            visits.length >= AkgReference.ancTarget
                                ? 'Semua kunjungan minimal tercatat.'
                                : '${AkgReference.ancTarget - visits.length} kunjungan lagi. Jadwalkan lebih awal.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _UsgScheduleCard(),
                    const SizedBox(height: 16),
                    SectionHeader(
                      title: 'Jadwal kunjungan',
                      subtitle:
                          '${visits.length} dari ${AkgReference.ancTarget} tercatat',
                      actionLabel: 'Catat',
                      onAction: () => _openForm(context),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_schedule.length, (index) {
                      final item = _schedule[index];
                      final visit = index < visits.length
                          ? visits[index]
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _AncTile(
                          index: index + 1,
                          title: item.$1,
                          period: item.$2,
                          description: item.$3,
                          visit: visit,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    NuriButton(
                      label: 'Catat kunjungan ANC',
                      icon: Icons.add_rounded,
                      onPressed: () => _openForm(context),
                    ),
                    const SizedBox(height: 14),
                    const InfoBanner(
                      title: 'Yang diperiksa saat ANC',
                      body: 'Berat badan, tekanan darah, LiLA, Hb, tinggi fundus, dan gerakan janin. Bawa Buku KIA setiap kunjungan.',
                      icon: Icons.fact_check_outlined,
                    ),
                    const SizedBox(height: 10),
                    const InfoBanner(
                      title: 'Segera ke faskes bila',
                      body: 'Perdarahan, nyeri perut hebat, pusing berat, pandangan kabur, bengkak mendadak, atau gerakan janin berkurang.',
                      icon: Icons.warning_amber_rounded,
                      background: AppColors.redSoft,
                      foreground: AppColors.red,
                    ),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context) {
    showNuriSheet(
      context: context,
      builder: (context) => const _AncFormSheet(),
    );
  }
}

class _AncTile extends StatelessWidget {
  const _AncTile({
    required this.index,
    required this.title,
    required this.period,
    required this.description,
    required this.visit,
  });

  final int index;
  final String title;
  final String period;
  final String description;
  final AncVisit? visit;

  @override
  Widget build(BuildContext context) {
    final done = visit != null;
    return AppCard(
      padding: const EdgeInsets.all(13),
      color: done ? AppColors.surface : AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.mint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Pill(
                      label: done ? 'Tercatat' : period,
                      background: done
                          ? AppColors.mint
                          : AppColors.surfaceSubtle,
                      foreground: done ? AppColors.primary : AppColors.muted,
                      fontSize: 11,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                if (done) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${formatDateId(visit!.date)} • ${visit!.facility ?? 'Fasilitas kesehatan'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AncFormSheet extends ConsumerStatefulWidget {
  const _AncFormSheet();

  @override
  ConsumerState<_AncFormSheet> createState() => _AncFormSheetState();
}

class _AncFormSheetState extends ConsumerState<_AncFormSheet> {
  DateTime _date = dateOnly(DateTime.now());
  final _facility = TextEditingController(text: 'Posyandu Melati II');
  final _note = TextEditingController();

  @override
  void dispose() {
    _facility.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(appControllerProvider.notifier)
        .addAncVisit(
          date: _date,
          facility: _facility.text.trim().isEmpty
              ? null
              : _facility.text.trim(),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    Navigator.of(context).pop();
    showNuriSnack(context, 'Kunjungan ANC tercatat.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catat kunjungan ANC',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Catat pemeriksaan yang sudah dilakukan bersama bidan atau dokter.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          NuriDateField(
            label: 'Tanggal kunjungan',
            value: _date,
            firstDate: DateTime.now().subtract(const Duration(days: 300)),
            lastDate: DateTime.now(),
            onChanged: (value) => setState(() => _date = dateOnly(value)),
          ),
          const SizedBox(height: 12),
          NuriTextField(
            label: 'Fasilitas / tenaga kesehatan',
            controller: _facility,
            hint: 'Posyandu, puskesmas, atau bidan',
            prefixIcon: Icons.local_hospital_outlined,
          ),
          const SizedBox(height: 12),
          NuriTextField(
            label: 'Catatan (opsional)',
            controller: _note,
            hint: 'Contoh: tekanan darah normal, imunisasi TT',
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: 'Simpan kunjungan',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class PregnancyCheckupScreen extends ConsumerWidget {
  const PregnancyCheckupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Pemeriksaan kehamilan',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(title: 'Tidak ada kehamilan aktif'),
              ),
            ],
          ),
        ),
      );
    }
    final checkups = List<Checkup>.from(pregnancy.checkups)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Pemeriksaan kehamilan',
              subtitle: '${checkups.length} catatan',
              onBack: () => Navigator.of(context).pop(),
              action: RoundIconButton(
                icon: Icons.add_rounded,
                filled: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckupFormScreen()),
                ),
              ),
            ),
            Expanded(
              child: checkups.isEmpty
                  ? EmptyState(
                      title: 'Belum ada pemeriksaan',
                      body:
                          'Catat hasil pemeriksaan dari bidan atau puskesmas.',
                      icon: Icons.monitor_heart_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: checkups.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == checkups.length) {
                          return Column(
                            children: [
                              const SizedBox(height: 4),
                              NuriButton(
                                label: 'Catat pemeriksaan baru',
                                icon: Icons.add_rounded,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckupFormScreen(),
                                  ),
                                ),
                              ),
                              const NuriDisclaimer(),
                            ],
                          );
                        }
                        return _CheckupTile(checkup: checkups[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckupTile extends StatelessWidget {
  const _CheckupTile({required this.checkup});

  final Checkup checkup;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _showDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: checkup.needsConsultation
                      ? AppColors.redSoft
                      : AppColors.mint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.monitor_heart_outlined,
                  size: 19,
                  color: checkup.needsConsultation
                      ? AppColors.red
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDateId(checkup.date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${checkup.source == 'kader' ? 'Kader' : 'Mandiri'} • ${checkup.recordedBy}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (checkup.needsConsultation)
                const Pill(
                  label: 'Perlu konsultasi',
                  icon: Icons.warning_amber_rounded,
                  background: AppColors.redSoft,
                  foreground: AppColors.red,
                  fontSize: 11,
                )
              else
                const Pill(
                  label: 'Dalam batas',
                  icon: Icons.check_circle_outline_rounded,
                  background: AppColors.mint,
                  foreground: AppColors.primary,
                  fontSize: 11,
                ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              _CheckupValue(
                label: 'Berat',
                value: '${fmt1(checkup.weightKg)} kg',
              ),
              _CheckupValue(
                label: 'LiLA',
                value: '${fmt1(checkup.lilaCm)} cm',
                warning: checkup.lilaCm < 23.5,
              ),
              _CheckupValue(
                label: 'Hb',
                value: checkup.hbGdl == null
                    ? '—'
                    : '${fmt1(checkup.hbGdl)} g/dL',
                warning: checkup.hbGdl != null && checkup.hbGdl! < 11,
              ),
              _CheckupValue(
                label: 'Tekanan',
                value: checkup.systolic == null
                    ? '—'
                    : '${checkup.systolic}/${checkup.diastolic}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showNuriSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pemeriksaan ${formatDateId(checkup.date)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            NuriInfoRow(
              icon: Icons.monitor_weight_outlined,
              title: 'Berat badan',
              subtitle: '${fmt1(checkup.weightKg)} kg',
            ),
            const SizedBox(height: 8),
            NuriInfoRow(
              icon: Icons.straighten_rounded,
              title: 'Lingkar lengan atas (LiLA)',
              subtitle: checkup.lilaCm < 23.5
                  ? '${fmt1(checkup.lilaCm)} cm • di bawah 23,5 cm'
                  : '${fmt1(checkup.lilaCm)} cm • dalam batas',
              color: checkup.lilaCm < 23.5 ? AppColors.red : AppColors.primary,
              background: checkup.lilaCm < 23.5
                  ? AppColors.redSoft
                  : AppColors.mint,
            ),
            const SizedBox(height: 8),
            NuriInfoRow(
              icon: Icons.science_outlined,
              title: 'Hemoglobin (Hb)',
              subtitle: checkup.hbGdl == null
                  ? 'Tidak dicatat'
                  : checkup.hbGdl! < 11
                  ? '${fmt1(checkup.hbGdl)} g/dL • anemia'
                  : '${fmt1(checkup.hbGdl)} g/dL • dalam batas',
              color: checkup.hbGdl != null && checkup.hbGdl! < 11
                  ? AppColors.red
                  : AppColors.primary,
              background: checkup.hbGdl != null && checkup.hbGdl! < 11
                  ? AppColors.redSoft
                  : AppColors.mint,
            ),
            const SizedBox(height: 8),
            NuriInfoRow(
              icon: Icons.favorite_outline_rounded,
              title: 'Tekanan darah',
              subtitle: checkup.systolic == null
                  ? 'Tidak dicatat'
                  : '${checkup.systolic}/${checkup.diastolic} mmHg',
            ),
            if (checkup.needsConsultation) ...[
              const SizedBox(height: 12),
              const InfoBanner(
                title: 'Perlu konsultasi',
                body: 'LiLA < 23,5 cm atau Hb < 11 g/dL. Diskusikan dengan bidan atau dokter untuk tindak lanjut.',
                icon: Icons.warning_amber_rounded,
                background: AppColors.redSoft,
                foreground: AppColors.red,
              ),
            ],
            const SizedBox(height: 10),
            const NuriDisclaimer(compact: true),
          ],
        ),
      ),
    );
  }
}

class _CheckupValue extends StatelessWidget {
  const _CheckupValue({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: warning ? AppColors.red : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckupFormScreen extends ConsumerStatefulWidget {
  const CheckupFormScreen({super.key});

  @override
  ConsumerState<CheckupFormScreen> createState() => _CheckupFormScreenState();
}

class _CheckupFormScreenState extends ConsumerState<CheckupFormScreen> {
  final _weight = TextEditingController();
  final _lila = TextEditingController();
  final _hb = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  DateTime _date = dateOnly(DateTime.now());

  @override
  void dispose() {
    _weight.dispose();
    _lila.dispose();
    _hb.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    super.dispose();
  }

  double? _value(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  void _save() {
    final weight = _value(_weight);
    final lila = _value(_lila);
    if (weight == null || weight <= 0 || lila == null || lila <= 0) {
      showNuriSnack(
        context,
        'Berat dan LiLA wajib diisi dengan benar.',
        error: true,
      );
      return;
    }
    final hb = _value(_hb);
    final systolic = int.tryParse(_systolic.text.trim());
    final diastolic = int.tryParse(_diastolic.text.trim());
    ref
        .read(appControllerProvider.notifier)
        .addCheckup(
          weightKg: weight,
          lilaCm: lila,
          hbGdl: hb,
          systolic: systolic,
          diastolic: diastolic,
          date: _date,
        );
    Navigator.of(context).pop();
    showNuriSnack(context, 'Pemeriksaan tersimpan.');
  }

  @override
  Widget build(BuildContext context) {
    final hb = _value(_hb);
    final lila = _value(_lila);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Catat pemeriksaan',
              subtitle: 'Hasil dari bidan atau puskesmas',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          NuriDateField(
                            label: 'Tanggal pemeriksaan',
                            value: _date,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 300),
                            ),
                            lastDate: DateTime.now(),
                            onChanged: (value) =>
                                setState(() => _date = dateOnly(value)),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: NuriTextField(
                                  label: 'Berat badan (kg)',
                                  controller: _weight,
                                  hint: '58,5',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NuriTextField(
                                  label: 'LiLA (cm)',
                                  controller: _lila,
                                  hint: '24,5',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          NuriTextField(
                            label: 'Hemoglobin / Hb (g/dL, opsional)',
                            controller: _hb,
                            hint: '11,8',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: NuriTextField(
                                  label: 'Tekanan sistolik',
                                  controller: _systolic,
                                  hint: '115',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NuriTextField(
                                  label: 'Tekanan diastolik',
                                  controller: _diastolic,
                                  hint: '75',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (lila != null && lila < 23.5) ...[
                      const SizedBox(height: 10),
                      const InfoBanner(
                        title: 'LiLA di bawah 23,5 cm',
                        body: 'Indikasi risiko kekurangan energi kronis (KEK). Perlu konsultasi dan tindak lanjut tenaga kesehatan.',
                        icon: Icons.warning_amber_rounded,
                        background: AppColors.amberSoft,
                        foreground: AppColors.amber,
                      ),
                    ],
                    if (hb != null && hb < 11) ...[
                      const SizedBox(height: 10),
                      const InfoBanner(
                        title: 'Hb di bawah 11 g/dL',
                        body: 'Indikasi anemia pada kehamilan. Diskusikan suplementasi dan pola makan dengan bidan atau dokter.',
                        icon: Icons.warning_amber_rounded,
                        background: AppColors.redSoft,
                        foreground: AppColors.red,
                      ),
                    ],
                    const SizedBox(height: 14),
                    const InfoBanner(
                      title: 'Catatan',
                      body: 'NURI hanya menyimpan hasil yang Ibu masukkan. Pemeriksaan tetap dilakukan oleh tenaga kesehatan.',
                      icon: Icons.verified_user_outlined,
                    ),
                    const SizedBox(height: 14),
                    NuriButton(
                      label: 'Simpan pemeriksaan',
                      icon: Icons.check_rounded,
                      onPressed: _save,
                    ),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GiveBirthScreen extends ConsumerStatefulWidget {
  const GiveBirthScreen({super.key});

  @override
  ConsumerState<GiveBirthScreen> createState() => _GiveBirthScreenState();
}

class _GiveBirthScreenState extends ConsumerState<GiveBirthScreen> {
  final _name = TextEditingController();
  DateTime _dob = dateOnly(DateTime.now());
  Sex _sex = Sex.male;
  final _weight = TextEditingController();
  final _length = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _length.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 2) {
      showNuriSnack(
        context,
        'Nama panggilan bayi minimal 2 karakter.',
        error: true,
      );
      return;
    }
    final child = ref
        .read(appControllerProvider.notifier)
        .giveBirth(
          dob: _dob,
          sex: _sex,
          nickname: _name.text,
          birthWeightKg: double.tryParse(_weight.text.replaceAll(',', '.')),
          birthLengthCm: double.tryParse(_length.text.replaceAll(',', '.')),
        );
    if (child == null) {
      showNuriSnack(
        context,
        'Data kehamilan aktif tidak ditemukan.',
        error: true,
      );
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selamat, Ibu!'),
        content: Text(
          '${child.nickname} sudah lahir. Data kehamilan disimpan sebagai riwayat dan Ibu dapat mulai mencatat tumbuh kembang Si Kecil.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mulai pantau'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Catat kelahiran',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(title: 'Tidak ada kehamilan aktif'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Catat kelahiran',
              subtitle: 'Satu langkah lagi untuk memulai 1000 HPK',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InfoBanner(
                      title: 'Selamat atas kelahiran Si Kecil',
                      body: 'Setelah disimpan, data kehamilan menjadi riwayat dan fokus berpindah ke tumbuh kembang bayi.',
                      icon: Icons.celebration_outlined,
                      background: AppColors.peachSoft,
                      foreground: AppColors.coral,
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          NuriTextField(
                            label: 'Nama panggilan bayi',
                            controller: _name,
                            hint: 'Contoh: Rafi',
                            prefixIcon: Icons.child_care_rounded,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 12),
                          NuriDateField(
                            label: 'Tanggal lahir',
                            value: _dob,
                            firstDate: pregnancy.hpht,
                            lastDate: DateTime.now(),
                            onChanged: (value) =>
                                setState(() => _dob = dateOnly(value)),
                          ),
                          const SizedBox(height: 12),
                          const NuriFormLabel(text: 'Jenis kelamin'),
                          NuriSegmentedControl<Sex>(
                            values: const [Sex.male, Sex.female],
                            selected: _sex,
                            labelFor: (value) => value.label,
                            onChanged: (value) => setState(() => _sex = value),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: NuriTextField(
                                  label: 'BB lahir (kg, opsional)',
                                  controller: _weight,
                                  hint: '3,1',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NuriTextField(
                                  label: 'PB lahir (cm, opsional)',
                                  controller: _length,
                                  hint: '49',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const InfoBanner(
                      title: 'ASI eksklusif 6 bulan',
                      body: 'Mulai menyusui sesegera mungkin, lakukan IMD bila memungkinkan, dan lanjutkan ASI sampai 2 tahun.',
                      icon: Icons.water_drop_outlined,
                    ),
                    const SizedBox(height: 14),
                    NuriButton(
                      label: 'Simpan kelahiran',
                      icon: Icons.check_rounded,
                      onPressed: _save,
                    ),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsgScheduleCard extends StatelessWidget {
  const _UsgScheduleCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skrining USG Kehamilan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Standar Kemenkes RI: Minimal 2x oleh Dokter',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _UsgMilestoneTile(
            number: '1',
            trimester: 'Trimester 1 (< 12 minggu)',
            title: 'Skrining Awal & Deteksi Dini',
            description: 'Menentukan kepastian HPL, lokasi kehamilan dalam rahim, jumlah janin, dan denyut jantung janin.',
          ),
          const SizedBox(height: 10),
          const _UsgMilestoneTile(
            number: '2',
            trimester: 'Trimester 3 (32–36 minggu)',
            title: 'Skrining Kesiapan Persalinan',
            description: 'Menilai pertumbuhan janin, perkiraan berat lahir (cegah BBLR/stunting), posisi plasenta, dan kecukupan air ketuban.',
          ),
        ],
      ),
    );
  }
}

class _UsgMilestoneTile extends StatelessWidget {
  const _UsgMilestoneTile({
    required this.number,
    required this.trimester,
    required this.title,
    required this.description,
  });

  final String number;
  final String trimester;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trimester,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
