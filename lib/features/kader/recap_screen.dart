import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'recap_details.dart';
import 'recap_widgets.dart';

class RecapScreen extends ConsumerWidget {
  const RecapScreen({super.key, this.embedded = true});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final session = state.activeSession;
    final roster = state.myRoster;
    final children = roster.where((r) => r.type == RosterType.child).toList();
    final categorized = children.where((r) => r.category != null).toList();
    final normal = categorized
        .where((r) => r.category == GrowthCategory.normal)
        .length;
    final stunted = categorized
        .where((r) => r.category == GrowthCategory.stunted)
        .length;
    final severe = categorized
        .where((r) => r.category == GrowthCategory.severelyStunted)
        .length;
    final tall = categorized
        .where((r) => r.category == GrowthCategory.tall)
        .length;
    final present = roster
        .where((r) => r.attendance == AttendanceStatus.present)
        .length;
    final waiting = roster
        .where((r) => r.attendance == AttendanceStatus.waiting)
        .length;
    final absent = roster
        .where((r) => r.attendance == AttendanceStatus.absent)
        .length;
    final followUps = roster.where((r) => r.needsFollowUp).toList();
    final target = session?.targetCount ?? roster.length;
    final done = session?.isDone ?? false;

    final exportButton = RecapExportButton(
      onTap: () => _export(context, state),
    );
    final subtitle = session == null
        ? 'Belum ada sesi aktif'
        : '${session.posyanduName} • ${formatDateId(session.date, withYear: false)}';

    final content = SingleChildScrollView(
      padding: EdgeInsets.only(bottom: embedded ? 96 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurvedHeader(
            borderRadius: 32,
            padding: EdgeInsets.fromLTRB(
              20,
              embedded ? MediaQuery.paddingOf(context).top + 8 : 12,
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
                                Icons.insert_chart_rounded,
                                size: 13,
                                color: AppColors.secondaryFixed,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Laporan',
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
                    exportButton,
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Rekap Hasil Sesi',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
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
          if (session == null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: EmptyState(
                title: 'Belum ada sesi',
                body: 'Buat sesi Posyandu terlebih dahulu untuk melihat rekap.',
                icon: Icons.event_busy_rounded,
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RecapSessionSummaryCard(
                session: session,
                present: present,
                target: target,
                done: done,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  RecapStatCard(
                    label: 'Sasaran',
                    value: '$target',
                    icon: Icons.groups_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  RecapStatCard(
                    label: 'Hadir',
                    value: '$present',
                    icon: Icons.how_to_reg_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  RecapStatCard(
                    label: 'Belum',
                    value: '${waiting + absent}',
                    icon: Icons.person_off_outlined,
                    color: AppColors.amber,
                  ),
                  const SizedBox(width: 8),
                  RecapStatCard(
                    label: 'Tindak',
                    value: '${followUps.length}',
                    icon: Icons.follow_the_signs_rounded,
                    color: AppColors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                title: 'Status gizi balita',
                subtitle: 'Panjang/tinggi badan menurut umur • WHO 2006',
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RecapDistributionDetail(
                normal: normal,
                stunted: stunted,
                severe: severe,
                tall: tall,
                total: categorized.length,
              ),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(title: 'Kehadiran'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RecapAttendanceCard(
                present: present,
                waiting: waiting,
                absent: absent,
                target: target,
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                title: 'Daftar tindak lanjut',
                subtitle: '${followUps.length} sasaran perlu ditindaklanjuti',
              ),
            ),
            const SizedBox(height: 10),
            if (followUps.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: InfoBanner(
                  title: 'Tidak ada tindak lanjut terbuka',
                  body: 'Semua sasaran pada sesi ini sudah tercatat.',
                  icon: Icons.task_alt_rounded,
                ),
              )
            else
              ...followUps
                  .take(6)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: RecapFollowUpRow(entry: entry),
                    ),
                  ),
            if (followUps.length > 6)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                child: Text(
                  '+${followUps.length - 6} sasaran lainnya ada di tab Tindak Lanjut.',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NuriButton(
                label: done ? 'Sesi sudah selesai' : 'Selesaikan sesi',
                icon: done
                    ? Icons.lock_outline_rounded
                    : Icons.check_circle_outline_rounded,
                variant: done
                    ? NuriButtonVariant.outlined
                    : NuriButtonVariant.filled,
                onPressed: done
                    ? null
                    : () async {
                        final ok = await showNuriConfirm(
                          context: context,
                          title: 'Selesaikan sesi?',
                          message: 'Rekap akan dikunci. Data yang tertunda tetap tersimpan di perangkat dan disinkronkan saat online.',
                          confirmLabel: 'Selesaikan',
                        );
                        if (!ok) return;
                        ref
                            .read(appControllerProvider.notifier)
                            .completeSession();
                        if (context.mounted) {
                          showNuriSnack(
                            context,
                            'Sesi selesai dan rekap dikunci.',
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NuriDisclaimer(),
            ),
          ],
        ],
      ),
    );

    if (embedded) return content;
    return Scaffold(backgroundColor: AppColors.background, body: content);
  }

  Future<void> _export(BuildContext context, AppState state) async {
    final rows = <List<String>>[
      [
        'Nama',
        'Jenis',
        'Usia (bulan)',
        'JK',
        'Kehadiran',
        'Status gizi',
        'LiLA (cm)',
        'Hb (g/dL)',
        'Tindak lanjut',
      ],
      ...state.roster.map(
        (entry) => [
          entry.name,
          entry.type.label,
          entry.ageMonths?.toString() ?? '',
          entry.sex?.short ?? '',
          entry.attendance.label,
          entry.category?.label ?? '',
          entry.lilaCm?.toStringAsFixed(1) ?? '',
          entry.hbGdl?.toStringAsFixed(1) ?? '',
          entry.followUpStatus.label,
        ],
      ),
    ];
    final csv = rows.map((row) => row.map(_csvCell).join(',')).join('\n');
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) return;
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ekspor rekap CSV',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${state.roster.length} baris disalin ke clipboard. Tempel ke Excel atau e-PPGBM.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: SingleChildScrollView(
                child: Text(
                  csv,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            NuriButton(
              label: 'Tutup',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _csvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
