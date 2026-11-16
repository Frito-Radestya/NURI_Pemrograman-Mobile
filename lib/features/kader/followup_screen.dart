import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'followup_sheets.dart';
import 'followup_widgets.dart';

class FollowUpScreen extends ConsumerStatefulWidget {
  const FollowUpScreen({super.key, this.embedded = true});

  final bool embedded;

  @override
  ConsumerState<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends ConsumerState<FollowUpScreen> {
  FollowUpStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final all = state.myRoster.where((r) => r.needsFollowUp).toList()
      ..sort((a, b) {
        if (a.priority != b.priority) return a.priority ? -1 : 1;
        return a.name.compareTo(b.name);
      });
    final visible = _filter == null
        ? all
        : all.where((r) => r.followUpStatus == _filter).toList();
    final open = all
        .where((r) => r.followUpStatus == FollowUpStatus.open)
        .length;
    final visited = all
        .where((r) => r.followUpStatus == FollowUpStatus.visited)
        .length;
    final referred = all
        .where((r) => r.followUpStatus == FollowUpStatus.referred)
        .length;

    final content = Column(
      children: [
        CurvedHeader(
          borderRadius: 32,
          padding: EdgeInsets.fromLTRB(
            20,
            widget.embedded ? MediaQuery.paddingOf(context).top + 8 : 12,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (!widget.embedded && Navigator.of(context).canPop())
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
                          children: [
                            Icon(
                              Icons.follow_the_signs_rounded,
                              size: 13,
                              color: AppColors.secondaryFixed,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Intervensi 2T',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cloud_done_rounded,
                          size: 13,
                          color: AppColors.secondaryFixed,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Offline Siap',
                          style: TextStyle(
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
              const SizedBox(height: 10),
              const Text(
                'Tindak Lanjut Sasaran',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${all.length} sasaran perlu pendampingan atau rujukan faskes',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              FollowUpSummaryTile(
                label: 'Terbuka',
                value: open,
                color: AppColors.amber,
                background: AppColors.amberSoft,
                icon: Icons.error_outline_rounded,
              ),
              const SizedBox(width: 9),
              FollowUpSummaryTile(
                label: 'Dikunjungi',
                value: visited,
                color: AppColors.blue,
                background: AppColors.blueSoft,
                icon: Icons.home_outlined,
              ),
              const SizedBox(width: 9),
              FollowUpSummaryTile(
                label: 'Dirujuk',
                value: referred,
                color: AppColors.red,
                background: AppColors.redSoft,
                icon: Icons.local_hospital_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              FollowUpFilterChip(
                label: 'Semua',
                count: all.length,
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              const SizedBox(width: 7),
              ...FollowUpStatus.values.map(
                (status) => Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: FollowUpFilterChip(
                    label: FollowUpCard.shortStatus(status),
                    count: all.where((r) => r.followUpStatus == status).length,
                    selected: _filter == status,
                    onTap: () => setState(() => _filter = status),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: visible.isEmpty
              ? const EmptyState(
                  title: 'Tidak ada tindak lanjut',
                  body: 'Semua sasaran pada filter ini sudah tertangani.',
                  icon: Icons.task_alt_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) => FollowUpCard(
                    entry: visible[index],
                    onTap: () => _showDetail(context, visible[index]),
                  ),
                ),
        ),
      ],
    );

    if (widget.embedded) return content;
    return Scaffold(backgroundColor: AppColors.background, body: content);
  }

  Future<void> _showDetail(BuildContext context, RosterEntry entry) async {
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => FollowUpDetailSheet(
        entry: entry,
        onRecord: () {
          Navigator.of(sheetContext).pop();
          _showRecordSheet(context, entry);
        },
      ),
    );
  }

  Future<void> _showRecordSheet(BuildContext context, RosterEntry entry) async {
    await showNuriSheet<void>(
      context: context,
      builder: (_) => RecordFollowUpSheet(entry: entry),
    );
  }
}
