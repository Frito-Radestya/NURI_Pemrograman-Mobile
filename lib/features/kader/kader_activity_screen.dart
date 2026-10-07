import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_tabs.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../data/nuri_repository.dart' show ScreeningRecord, SyncState;
import '../../domain/models/child.dart';
import '../../domain/models/food_log.dart';
import '../../domain/models/growth_status.dart';
import '../../state/app_state.dart';

/// Riwayat aktivitas & catatan pengukuran serta makanan balita.
class KaderActivityScreen extends StatelessWidget {
  const KaderActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);

    final List<ScreeningRecord> screenings =
        List<ScreeningRecord>.of(state.repo.allScreenings)
          ..sort((ScreeningRecord a, ScreeningRecord b) => b
              .measurement.measuredOn
              .compareTo(a.measurement.measuredOn));
    final List<FoodLogItem> foods = List<FoodLogItem>.of(state.repo.allFoodItems)
      ..sort((FoodLogItem a, FoodLogItem b) =>
          b.createdAt.compareTo(a.createdAt));

    return NuriScaffold(
      bottomNavigationBar: const KaderTabBar(active: '/kader-activity'),
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/kader'),
        titleWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NURI HEALTH', style: AppText.caption),
            SizedBox(height: 2),
            Text('Riwayat Aktivitas & Catatan', style: AppText.h3),
          ],
        ),
        actions: [
          NuriSoftButton(icon: Icons.filter_list_rounded, onPressed: () {}),
          const SizedBox(width: 8),
          NuriSoftButton(icon: Icons.ios_share_rounded, onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        children: [
          // Ringkasan.
          NuriCard(
            color: AppColors.canvasMint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Aktivitas', style: AppText.h3),
                const SizedBox(height: 4),
                Text(state.storageLabel, style: AppText.bodySm),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatCol(
                        value: '${screenings.length}',
                        label: 'Pengukuran',
                      ),
                    ),
                    Expanded(
                      child: _StatCol(
                        value: '${foods.length}',
                        label: 'Catatan Makan',
                        color: AppColors.accent,
                      ),
                    ),
                    Expanded(
                      child: _StatCol(
                        value: '${state.pendingCount}',
                        label: 'Menunggu Sinkron',
                        color: state.pendingCount == 0
                            ? AppColors.statusNormal
                            : AppColors.statusPendek,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tag(text: '${state.children.length} Balita'),
              Tag(text: _syncLabel(state.syncState)),
              if (state.lastSyncedAt != null)
                Tag(text: 'Terakhir ${_formatDate(state.lastSyncedAt!)}'),
            ],
          ),
          const SizedBox(height: 20),

          const _SectionLabel(title: 'Riwayat Pengukuran'),
          const SizedBox(height: 12),
          if (screenings.isEmpty)
            const NoteBox(
              background: AppColors.surfaceSoft,
              icon: Icons.straighten_rounded,
              child: Text(
                'Belum ada riwayat pengukuran. Catat pengukuran dari menu '
                'Ukur & Catat Balita.',
                style: AppText.bodySm,
              ),
            )
          else
            for (final ScreeningRecord record in screenings) ...[
              _ScreeningCard(
                child: state.childById(record.measurement.childId),
                record: record,
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 20),

          const _SectionLabel(title: 'Riwayat Makanan'),
          const SizedBox(height: 12),
          if (foods.isEmpty)
            const NoteBox(
              background: AppColors.surfaceSoft,
              icon: Icons.restaurant_outlined,
              child: Text(
                'Belum ada catatan makanan. Entri makan akan muncul di sini.',
                style: AppText.bodySm,
              ),
            )
          else
            for (final FoodLogItem item in foods) ...[
              _FoodCard(
                child: state.childById(item.childId),
                item: item,
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _ScreeningCard extends StatelessWidget {
  const _ScreeningCard({required this.child, required this.record});

  final Child? child;
  final ScreeningRecord record;

  @override
  Widget build(BuildContext context) {
    final GrowthStatus status = record.result.status;
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBadge(
                icon: Icons.straighten_rounded,
                color: AppColors.pastelBlue,
                iconColor: Color(0xFF2F6FB5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child?.nickname ?? 'Balita',
                      style: AppText.h3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(record.measurement.measuredOn)} • '
                      '${record.result.ageMonths} bulan • '
                      'Kader Posyandu',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Metric(
                  label: 'Berat Badan',
                  value:
                      '${record.measurement.weightKg.toStringAsFixed(1)} kg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  label: 'Tinggi Badan',
                  value:
                      '${record.measurement.lengthHeightCm.toStringAsFixed(1)} cm',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  label: 'Z-Score',
                  value: '${record.result.zLabel} SD',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatusChip(
            text: 'Status: ${status.label}',
            color: _statusSoft(status),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.child, required this.item});

  final Child? child;
  final FoodLogItem item;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.pastelGreenSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.foodName, style: AppText.h3),
                const SizedBox(height: 2),
                Text(
                  '${child?.nickname ?? 'Balita'} • ${item.meal.label} • '
                  '${_formatDate(item.logDate)}',
                  style: AppText.caption,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Tag(text: '${item.energy.round()} kkal'),
                    Tag(text: item.portionLabel),
                    Tag(text: item.group),
                    Tag(text: item.source.label),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppText.h3);
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({
    required this.value,
    required this.label,
    this.color = AppColors.brand,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.metric.copyWith(color: color, fontSize: 22)),
        const SizedBox(height: 2),
        Text(label, style: AppText.caption),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 3),
        Text(value, style: AppText.title.copyWith(fontSize: 14.5)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Utilitas.
// ---------------------------------------------------------------------------

String _syncLabel(SyncState state) {
  switch (state) {
    case SyncState.offline:
      return 'Offline';
    case SyncState.syncing:
      return 'Menyinkronkan';
    case SyncState.pending:
      return 'Menunggu Sinkron';
    case SyncState.synced:
      return 'Tersinkron';
  }
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
