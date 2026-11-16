import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'followup_widgets.dart';

class FollowUpDetailSheet extends StatelessWidget {
  const FollowUpDetailSheet({
    super.key,
    required this.entry,
    required this.onRecord,
  });

  final RosterEntry entry;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final colors = FollowUpCard.colorsFor(entry.followUpStatus);
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

class RecordFollowUpSheet extends ConsumerStatefulWidget {
  const RecordFollowUpSheet({super.key, required this.entry});

  final RosterEntry entry;

  @override
  ConsumerState<RecordFollowUpSheet> createState() =>
      _RecordFollowUpSheetState();
}

class _RecordFollowUpSheetState extends ConsumerState<RecordFollowUpSheet> {
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
