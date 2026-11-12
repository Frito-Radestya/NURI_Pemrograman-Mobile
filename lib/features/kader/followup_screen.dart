import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

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
    final all = state.roster.where((r) => r.needsFollowUp).toList()
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

    const offlinePill = Pill(
      label: 'Offline siap',
      icon: Icons.cloud_off_rounded,
      background: AppColors.mint,
      foreground: AppColors.primaryDark,
      fontSize: 11.5,
    );

    final content = SafeArea(
      bottom: false,
      child: Column(
        children: [
          if (widget.embedded)
            NuriPageHeader(
              title: 'Tindak lanjut',
              subtitle: '${all.length} sasaran perlu perhatian',
              trailing: offlinePill,
            )
          else
            ScreenHeader(
              title: 'Tindak lanjut',
              subtitle: '${all.length} sasaran perlu perhatian',
              onBack: () => Navigator.of(context).pop(),
              action: offlinePill,
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _SummaryTile(
                  label: 'Terbuka',
                  value: open,
                  color: AppColors.amber,
                  background: AppColors.amberSoft,
                  icon: Icons.error_outline_rounded,
                ),
                const SizedBox(width: 9),
                _SummaryTile(
                  label: 'Dikunjungi',
                  value: visited,
                  color: AppColors.blue,
                  background: AppColors.blueSoft,
                  icon: Icons.home_outlined,
                ),
                const SizedBox(width: 9),
                _SummaryTile(
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
                _FilterChip(
                  label: 'Semua',
                  count: all.length,
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 7),
                ...FollowUpStatus.values.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _FilterChip(
                      label: _FollowUpCard._shortStatus(status),
                      count: all
                          .where((r) => r.followUpStatus == status)
                          .length,
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (context, index) => _FollowUpCard(
                      entry: visible[index],
                      onTap: () => _showDetail(context, visible[index]),
                    ),
                  ),
          ),
        ],
      ),
    );

    if (widget.embedded) return content;
    return Scaffold(backgroundColor: AppColors.background, body: content);
  }

  Future<void> _showDetail(BuildContext context, RosterEntry entry) async {
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => _FollowUpDetailSheet(
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
      builder: (_) => _RecordFollowUpSheet(entry: entry),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
          ),
        ),
        child: Text(
          '$label  $count',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.entry, required this.onTap});

  final RosterEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(entry.followUpStatus);
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(name: entry.name, index: entry.avatarIndex, size: 44),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (entry.priority) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.priority_high_rounded,
                            size: 15,
                            color: AppColors.red,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.type == RosterType.child
                          ? '${entry.ageMonths ?? '—'} bulan • ${entry.guardianName}'
                          : '${entry.pregnancyWeeks ?? '—'} minggu • ${entry.guardianName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Pill(
                label: _shortStatus(entry.followUpStatus),
                background: statusColors.$1,
                foreground: statusColors.$2,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 15, color: statusColors.$2),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    entry.reason ?? 'Perlu konfirmasi kader',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(
                entry.lastMeasuredAt == null
                    ? Icons.event_busy_outlined
                    : Icons.straighten_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  entry.lastMeasuredAt == null
                      ? 'Belum ada pengukuran'
                      : 'Diukur ${formatDateId(entry.lastMeasuredAt!, withYear: false)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ),
              if (entry.pendingSync) const SyncBadge(pending: true),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: AppColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _shortStatus(FollowUpStatus status) => switch (status) {
    FollowUpStatus.open => 'Terbuka',
    FollowUpStatus.visited => 'Dikunjungi',
    FollowUpStatus.referred => 'Dirujuk',
    FollowUpStatus.unreachable => 'Absen',
    FollowUpStatus.closed => 'Selesai',
  };

  static (Color, Color) _statusColors(FollowUpStatus status) =>
      switch (status) {
        FollowUpStatus.open => (AppColors.amberSoft, AppColors.amber),
        FollowUpStatus.visited => (AppColors.blueSoft, AppColors.blue),
        FollowUpStatus.referred => (AppColors.redSoft, AppColors.red),
        FollowUpStatus.unreachable => (AppColors.purpleSoft, AppColors.purple),
        FollowUpStatus.closed => (AppColors.mint, AppColors.primary),
      };
}

class _FollowUpDetailSheet extends StatelessWidget {
  const _FollowUpDetailSheet({required this.entry, required this.onRecord});

  final RosterEntry entry;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final colors = _FollowUpCard._statusColors(entry.followUpStatus);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: entry.name, index: entry.avatarIndex, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.type == RosterType.child
                          ? 'Balita • ${entry.ageMonths ?? '—'} bulan'
                          : 'Ibu hamil • ${entry.pregnancyWeeks ?? '—'} minggu',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Pill(
                label: entry.followUpStatus.label,
                background: colors.$1,
                foreground: colors.$2,
                fontSize: 11.5,
              ),
            ],
          ),
          const SizedBox(height: 14),
          InfoBanner(
            title: 'Alasan tindak lanjut',
            body: entry.reason ?? 'Perlu konfirmasi kader',
            icon: Icons.flag_outlined,
            background: colors.$1,
            foreground: colors.$2,
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                NuriInfoRow(
                  icon: Icons.family_restroom_rounded,
                  title: 'Wali / pendamping',
                  subtitle: entry.guardianName.isEmpty
                      ? 'Belum diisi'
                      : entry.guardianName,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                NuriInfoRow(
                  icon: Icons.event_available_rounded,
                  title: 'Kehadiran sesi',
                  subtitle: entry.attendance.label,
                ),
                if (entry.lilaCm != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  NuriInfoRow(
                    icon: Icons.monitor_heart_outlined,
                    title: 'LiLA / Hb',
                    subtitle:
                        '${entry.lilaCm!.toStringAsFixed(1)} cm • '
                        '${entry.hbGdl?.toStringAsFixed(1) ?? '—'} g/dL',
                    color: AppColors.purple,
                    background: AppColors.purpleSoft,
                  ),
                ],
                if (entry.category != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  NuriInfoRow(
                    icon: Icons.show_chart_rounded,
                    title: 'Status gizi',
                    subtitle: entry.category!.label,
                    color: AppColors.amber,
                    background: AppColors.amberSoft,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: 'Catat hasil tindak lanjut',
            icon: Icons.edit_note_rounded,
            onPressed: onRecord,
          ),
          const SizedBox(height: 10),
          const NuriDisclaimer(compact: true),
        ],
      ),
    );
  }
}

class _RecordFollowUpSheet extends ConsumerStatefulWidget {
  const _RecordFollowUpSheet({required this.entry});

  final RosterEntry entry;

  @override
  ConsumerState<_RecordFollowUpSheet> createState() =>
      _RecordFollowUpSheetState();
}

class _RecordFollowUpSheetState extends ConsumerState<_RecordFollowUpSheet> {
  final _note = TextEditingController();
  FollowUpStatus _status = FollowUpStatus.visited;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catat tindak lanjut',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 3),
          Text(
            widget.entry.name,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          NuriSegmentedControl<FollowUpStatus>(
            values: const [
              FollowUpStatus.visited,
              FollowUpStatus.referred,
              FollowUpStatus.unreachable,
              FollowUpStatus.closed,
            ],
            selected: _status,
            labelFor: (value) => switch (value) {
              FollowUpStatus.visited => 'Dikunjungi',
              FollowUpStatus.referred => 'Dirujuk',
              FollowUpStatus.unreachable => 'Absen',
              _ => 'Selesai',
            },
            onChanged: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: 14),
          NuriTextField(
            label: 'Catatan (opsional)',
            controller: _note,
            hint: 'Contoh: ibu diberi edukasi MPASI, jadwal kontrol ulang…',
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          InfoBanner(
            title: _status == FollowUpStatus.referred
                ? 'Rujuk ke faskes'
                : 'Tercatat untuk sesi berikutnya',
            body: _status == FollowUpStatus.referred
                ? 'Pastikan ibu mendapat surat rujukan dan jadwal kontrol.'
                : 'Status tindak lanjut dapat diubah kembali bila ada informasi baru.',
            icon: _status == FollowUpStatus.referred
                ? Icons.local_hospital_outlined
                : Icons.check_circle_outline_rounded,
            background: _status == FollowUpStatus.referred
                ? AppColors.redSoft
                : AppColors.surfaceSubtle,
            foreground: _status == FollowUpStatus.referred
                ? AppColors.red
                : AppColors.text,
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: 'Simpan tindak lanjut',
            icon: Icons.check_rounded,
            onPressed: () {
              final note = _note.text.trim();
              ref
                  .read(appControllerProvider.notifier)
                  .recordFollowUp(
                    widget.entry.id,
                    _status,
                    note: note.isEmpty ? _status.label : note,
                  );
              Navigator.of(context).pop();
              showNuriSnack(
                context,
                'Tindak lanjut disimpan: ${_status.label}.',
              );
            },
          ),
        ],
      ),
    );
  }
}
