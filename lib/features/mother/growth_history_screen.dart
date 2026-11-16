import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import 'growth_history_widgets.dart';
import 'growth_measurement_screen.dart';

class GrowthHistoryScreen extends ConsumerWidget {
  const GrowthHistoryScreen({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    Child? child;
    for (final item in state.children) {
      if (item.id == childId) {
        child = item;
        break;
      }
    }
    if (child == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Riwayat',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(child: EmptyState(title: 'Data tidak ditemukan')),
            ],
          ),
        ),
      );
    }
    final list = List<Measurement>.from(child.measurements)
      ..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Riwayat pengukuran',
              subtitle: child.nickname,
              onBack: () => Navigator.of(context).pop(),
              action: RoundIconButton(
                icon: Icons.add_rounded,
                filled: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MeasurementInputScreen(childId: child!.id),
                  ),
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      title: 'Belum ada pengukuran',
                      body: 'Catat pengukuran pertama untuk melihat riwayat.',
                      icon: Icons.straighten_rounded,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final measurement = list[index];
                        return AppCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () => showMeasurementDetail(
                            context,
                            child!,
                            measurement,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.straighten_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDateId(measurement.date),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${measurement.ageMonths} bulan • ${fmt1(measurement.measuredCm)} cm • ${fmt1(measurement.weightKg)} kg',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GrowthStatusBadge(
                                category: measurement.category,
                                compact: true,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 19,
                                color: AppColors.muted,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
