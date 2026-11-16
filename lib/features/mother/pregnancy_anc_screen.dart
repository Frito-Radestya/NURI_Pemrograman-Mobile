import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'pregnancy_anc_form_sheet.dart';
import 'pregnancy_anc_widgets.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurvedHeader(
              borderRadius: 32,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + 16,
                16,
                22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      const NuriLogo(compact: true, onDark: true),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 13,
                              color: AppColors.secondaryFixed,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Standar 6x ANC',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kunjungan ANC Ibu',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Pemeriksaan kehamilan rutin (Antenatal Care) standar Kemenkes',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progres Kunjungan ANC',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Target Minimal 6x',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${visits.length} / ${AkgReference.ancTarget}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 8,
                          color: AppColors.surfaceContainerLow,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppGradients.button,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        visits.length >= AkgReference.ancTarget
                            ? 'Semua kunjungan minimal tercatat lengkap.'
                            : '${AkgReference.ancTarget - visits.length} kunjungan lagi untuk memenuhi standar.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AncUsgScheduleCard(),
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
                    final visit = index < visits.length ? visits[index] : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AncTile(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context) {
    showNuriSheet(context: context, builder: (context) => const AncFormSheet());
  }
}
