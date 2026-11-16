import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'growth_history_screen.dart';
import 'growth_history_widgets.dart';
import 'growth_summary_cards.dart';
import 'growth_who_chart_card.dart';
import 'growth_measurement_screen.dart';

class GrowthDetailScreen extends ConsumerWidget {
  const GrowthDetailScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final children = state.myChildren;
    final child = state.activeChild;

    final latest = child?.latestMeasurement;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: embedded ? 96 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Curved Organic Header (Inspired by UI_UX/nuri_pertumbuhan_anak)
            CurvedHeader(
              borderRadius: 32,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + 16,
                16,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!embedded && Navigator.of(context).canPop())
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
                      if (child != null) ...[
                        AppAvatar(
                          name: child.nickname,
                          index: child.avatarIndex,
                          size: 40,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                child.nickname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                '${child.sex.label} • ${child.ageLabel()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        const Expanded(
                          child: NuriLogo(
                            compact: false,
                            onDark: true,
                            subtitle: 'Tumbuh Kembang',
                          ),
                        ),
                      if (child != null) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  GrowthHistoryScreen(childId: child.id),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Riwayat',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MeasurementInputScreen(childId: child.id),
                            ),
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 19,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Inspection badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: AppColors.secondaryFixed,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            latest == null
                                ? 'Belum ada pemeriksaan'
                                : 'Pemeriksaan Terakhir: ${formatDateId(latest.date, withYear: false)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            state.posyanduName.isEmpty
                                ? 'Posyandu'
                                : state.posyanduName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (children.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: children.map((item) {
                      final selected = item.id == child?.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(item.nickname.split(' ').first),
                          selected: selected,
                          onSelected: (_) => ref
                              .read(appControllerProvider.notifier)
                              .selectChild(item.id),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.text,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (child == null)
              const EmptyState(
                title: 'Belum ada data anak',
                body: 'Tambahkan data anak untuk melihat grafik pertumbuhan.',
                icon: Icons.child_care_rounded,
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GrowthSummary(child: child),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GrowthWhoChartCard(child: child),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GrowthMeasurementNote(child: child),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Riwayat pengukuran',
                  subtitle: '${child.measurements.length} catatan tersimpan',
                  actionLabel: 'Semua',
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GrowthHistoryScreen(childId: child.id),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GrowthHistoryPreview(child: child),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: NuriDisclaimer(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
