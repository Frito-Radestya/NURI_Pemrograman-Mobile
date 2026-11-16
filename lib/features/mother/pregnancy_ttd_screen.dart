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
                            color: const Color(0xFF145C45)
                                .withValues(alpha: 0.2),
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
