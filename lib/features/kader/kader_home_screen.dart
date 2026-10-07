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
import '../../core/widgets/nutrient.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../data/nuri_repository.dart' show ScreeningRecord, SyncState;
import '../../domain/models/child.dart';
import '../../domain/models/growth_status.dart';
import '../../state/app_state.dart';

/// Beranda kader Posyandu: ringkasan kehadiran, tugas, dan sasaran berisiko.
class KaderHomeScreen extends StatelessWidget {
  const KaderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final String nama = state.user?.displayName ?? 'Kader';
    final String posyandu =
        state.user?.posyanduName ?? 'Posyandu Melati';
    final List<Child> children = state.children;

    final session = state.activeSession;
    final List<ScreeningRecord> sessionRecords = session == null
        ? const <ScreeningRecord>[]
        : state.screeningsInSession(session.id);
    final int hadir = sessionRecords.length;
    final Set<String> hadirIds = sessionRecords
        .map((ScreeningRecord r) => r.measurement.childId)
        .toSet();
    final int total = children.length;
    final int uniqueHadir = hadirIds.length;
    final int belumHadir = (total - uniqueHadir).clamp(0, total);
    final double persen = total == 0
        ? 0
        : (uniqueHadir / total).clamp(0.0, 1.0);

    int giziBaik = 0;
    int risikoStunting = 0;
    int intervensi = 0;
    int belumUkur = 0;
    for (final Child child in children) {
      final ScreeningRecord? record = state.latestScreening(child.id);
      if (record == null) {
        belumUkur++;
        continue;
      }
      switch (record.result.status) {
        case GrowthStatus.normal:
          giziBaik++;
        case GrowthStatus.tinggi:
          giziBaik++;
        case GrowthStatus.pendek:
          risikoStunting++;
        case GrowthStatus.sangatPendek:
          intervensi++;
      }
    }

    final List<Child> butuhPerhatian = children.where((Child child) {
      final ScreeningRecord? record = state.latestScreening(child.id);
      return record != null && record.result.status.needsFollowUp;
    }).toList();

    return NuriScaffold(
      bottomNavigationBar: const KaderTabBar(active: '/kader'),
      topBar: NuriTopBar(
        showBack: false,
        titleWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NURI', style: AppText.caption),
            SizedBox(height: 2),
            Text('Kader Posyandu', style: AppText.h3),
          ],
        ),
        actions: [
          NuriSoftButton(
            icon: Icons.notifications_none_rounded,
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
          NuriAvatar(initials: _initials(nama), size: 44),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: PillLabel(
                  text: 'Hari Buka Posyandu, Aksi (08:00 - 12:00)',
                ),
              ),
              Tag(text: session == null ? 'Belum ada sesi' : 'Sesi Aktif'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Semangat Pagi, $nama', style: AppText.h1),
          const SizedBox(height: 6),
          Text(
            'Kader $posyandu • ${state.user?.email ?? ''}',
            style: AppText.body,
          ),
          const SizedBox(height: 18),

          if (session == null)
            _NoSessionCard(
              onCreate: () => state.createSession(
                posyanduName: 'Posyandu Melati',
                heldOn: state.today,
              ),
            )
          else
            _AttendanceCard(
              hadir: hadir,
              total: total,
              persen: persen,
              belumHadir: belumHadir,
              sessionLabel: _formatDate(session.heldOn),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: NuriPrimaryButton(
                  label: 'Ukur & Catat Balita',
                  icon: Icons.add_rounded,
                  onPressed: () => context.go('/kader-entry'),
                ),
              ),
              const SizedBox(width: 12),
              NuriSoftButton(
                icon: Icons.groups_rounded,
                onPressed: () => context.go('/kader-targets'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SectionHeader(
            title: 'Tugas Hari Ini',
            actionLabel: session == null ? 'Buat sesi dahulu' : 'Sesi berjalan',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          ActionTile(
            title: 'Ukur & Catat Balita',
            subtitle:
                '$uniqueHadir anak sudah diukur pada sesi ini • $belumHadir tersisa',
            leading: const IconBadge(
              icon: Icons.fact_check_outlined,
              color: AppColors.pastelGreen,
            ),
            trailing: StatusChip(
              text: '$belumHadir Antrean',
              color: AppColors.pastelPeach,
            ),
            onTap: () => context.go('/kader-entry'),
          ),
          const SizedBox(height: 10),
          ActionTile(
            title: 'Evaluasi Balita Berisiko',
            subtitle: butuhPerhatian.isEmpty
                ? 'Belum ada balita yang butuh perhatian khusus'
                : 'Tindak lanjut tumbuh kembang & rujukan Puskesmas',
            leading: const IconBadge(
              icon: Icons.home_work_outlined,
              color: AppColors.pastelBlue,
              iconColor: Color(0xFF2F6FB5),
            ),
            trailing: Tag(text: '${butuhPerhatian.length} Sasaran'),
            onTap: () => context.go('/kader-targets'),
          ),
          const SizedBox(height: 24),

          SectionHeader(
            title: 'Anak Butuh Perhatian',
            actionLabel: 'Perlu intervensi segera',
            onAction: () => context.push('/kader-targets'),
          ),
          const SizedBox(height: 12),
          if (butuhPerhatian.isEmpty)
            const NoteBox(
              background: AppColors.pastelGreenSoft,
              icon: Icons.emoji_events_outlined,
              child: Text(
                'Semua balita terpantau baik. Tidak ada yang masuk kategori '
                'pendek atau sangat pendek pada pengukuran terakhir.',
                style: AppText.bodySm,
              ),
            )
          else
            for (final Child child in butuhPerhatian) ...[
              _AttentionCard(
                child: child,
                record: state.latestScreening(child.id)!,
                today: state.today,
                onRefer: () {
                  state.selectChild(child.id);
                  context.push('/kader-result');
                },
                onDetail: () {
                  state.selectChild(child.id);
                  context.push('/kader-target-detail');
                },
              ),
              const SizedBox(height: 12),
            ],
          if (butuhPerhatian.isNotEmpty)
            NuriSecondaryButton(
              label: 'Lihat Semua Sasaran Berisiko (${butuhPerhatian.length})',
              icon: Icons.arrow_forward_rounded,
              filled: true,
              onPressed: () => context.go('/kader-targets'),
            ),
          const SizedBox(height: 24),

          // Alur pelayanan.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alur Pelayanan 5 Langkah', style: AppText.h3),
                const SizedBox(height: 4),
                const Text(
                  'Panduan capaian meja Posyandu jika terintegrasi.',
                  style: AppText.bodySm,
                ),
                const SizedBox(height: 16),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _FlowTile(
                        number: '1',
                        title: 'Pendataan & KIA',
                        caption: 'Pendataan kinerja dasar',
                        icon: Icons.badge_outlined,
                        color: AppColors.pastelGreen,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _FlowTile(
                        number: '2',
                        title: 'Antropometri Cepat',
                        caption: 'Berat, tinggi, LiLA & Lingkar Kepala',
                        icon: Icons.straighten_rounded,
                        color: AppColors.pastelBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _FlowTile(
                        number: '3',
                        title: 'Layanan Gizi & Imunisasi',
                        caption: 'Vitamin A, obat cacing',
                        icon: Icons.vaccines_outlined,
                        color: AppColors.pastelYellow,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _FlowTile(
                        number: '4',
                        title: 'Konseling & Rujukan',
                        caption: 'Rujukan kebutuhan anak ke RS/Bimtek',
                        icon: Icons.support_agent_rounded,
                        color: AppColors.pastelPeach,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const NoteRow(
                  text:
                      'Langkah 5: Pelaporan & sinkronisasi data ke e-PPGBM.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Pemantauan sasaran.
          NuriCard(
            color: AppColors.canvasMint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Pemantauan Sasaran', style: AppText.h3),
                    ),
                    Tag(
                      text: state.syncState == SyncState.synced
                          ? 'Tersinkron'
                          : 'e-PPGBM Ready',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Rincian sasaran terbaru', style: AppText.bodySm),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL SASARAN BALITA ${total.toString().toUpperCase()}',
                        style: AppText.h2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('anak terdaftar', style: AppText.caption),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  total == 0
                      ? 'Belum ada data sasaran'
                      : '${((giziBaik / total) * 100).round()}% Terpantau Rutin',
                  style: AppText.caption,
                ),
                const SizedBox(height: 6),
                NutrientBar(
                  value: total == 0 ? 0 : giziBaik / total,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatCol(
                        value: '$giziBaik',
                        label:
                            'Gizi Baik (${_pct(giziBaik, total)})',
                      ),
                    ),
                    Expanded(
                      child: _StatCol(
                        value: '$risikoStunting',
                        label:
                            'Risiko Stunting (${_pct(risikoStunting, total)})',
                        color: AppColors.statusPendek,
                      ),
                    ),
                    Expanded(
                      child: _StatCol(
                        value: '$intervensi',
                        label:
                            'Intervensi Lanjutan (${_pct(intervensi, total)})',
                        color: AppColors.statusSangatPendek,
                      ),
                    ),
                  ],
                ),
                if (belumUkur > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    '$belumUkur balita belum memiliki data pengukuran.',
                    style: AppText.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          _SyncNote(state: state),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian lokal.
// ---------------------------------------------------------------------------

class _NoSessionCard extends StatelessWidget {
  const _NoSessionCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      color: AppColors.canvasGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.event_busy_outlined, color: AppColors.brand),
              SizedBox(width: 10),
              Expanded(
                child: Text('Belum Ada Sesi Posyandu', style: AppText.h3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat sesi hari ini untuk mulai mencatat pengukuran balita.',
            style: AppText.body,
          ),
          const SizedBox(height: 14),
          NuriPrimaryButton(
            label: 'Buat Sesi',
            icon: Icons.add_rounded,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.hadir,
    required this.total,
    required this.persen,
    required this.belumHadir,
    required this.sessionLabel,
  });

  final int hadir;
  final int total;
  final double persen;
  final int belumHadir;
  final String sessionLabel;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      color: AppColors.canvasGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Kehadiran $hadir dari $total Balita',
                  style: AppText.h3,
                ),
              ),
              const SizedBox(width: 8),
              Tag(text: 'Hadir (${(persen * 100).round()}%)'),
            ],
          ),
          const SizedBox(height: 4),
          Text('Sesi $sessionLabel', style: AppText.caption),
          const SizedBox(height: 14),
          NutrientBar(value: persen),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Target Sasaran: $total Anak',
                  style: AppText.caption,
                ),
              ),
              Text('$belumHadir Belum Hadir', style: AppText.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.child,
    required this.record,
    required this.today,
    required this.onRefer,
    required this.onDetail,
  });

  final Child child;
  final ScreeningRecord record;
  final DateTime today;
  final VoidCallback onRefer;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final GrowthStatus status = record.result.status;
    return NuriCard(
      border: _statusSoft(status),
      onTap: onDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChildHeader(
            initials: _initials(child.nickname),
            background: _statusSoft(status),
            name: child.nickname,
            age: child.ageLabelAt(today),
            meta:
                '${child.sex.label} • ${child.posyanduName ?? 'Posyandu Melati'}',
          ),
          const SizedBox(height: 10),
          StatusChip(
            text: '● ${status.label} • Z-Score ${record.result.zLabel} SD',
            color: _statusSoft(status),
          ),
          const SizedBox(height: 10),
          Text(status.plainLanguage, style: AppText.bodyStrong),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'BB',
                  value: '${record.measurement.weightKg.toStringAsFixed(1)} kg',
                  trend: 'Diukur ${_formatDate(record.measurement.measuredOn)}',
                  trendColor: _statusColor(status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniMetric(
                  label: 'TB',
                  value:
                      '${record.measurement.lengthHeightCm.toStringAsFixed(1)} cm',
                  trend: 'Z-Score TB/U: ${record.result.zLabel} SD',
                  trendColor: _statusColor(status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Buat Rujukan Puskesmas',
                  filled: true,
                  onPressed: onRefer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Detail Anak',
                  filled: true,
                  onPressed: onDetail,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncNote extends StatelessWidget {
  const _SyncNote({required this.state});

  final NuriAppState state;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String body;
    switch (state.syncState) {
      case SyncState.offline:
        title = 'Mode Offline';
        body = 'Data tersimpan aman di HP dan akan disinkronkan saat online.';
      case SyncState.syncing:
        title = 'Menyinkronkan…';
        body = 'Mengirim ${state.pendingCount} perubahan ke server Posyandu.';
      case SyncState.pending:
        title = 'Menunggu Sinkronisasi';
        body = '${state.pendingCount} perubahan belum terkirim ke server.';
      case SyncState.synced:
        title = 'Sinkronisasi Sukses!';
        body = state.lastSyncedAt == null
            ? 'Semua data sudah terkirim ke server Posyandu.'
            : 'Terakhir sinkron ${_formatDateTime(state.lastSyncedAt!)}.';
    }
    return NoteBox(
      background: AppColors.pastelGreenSoft,
      icon: Icons.sync_rounded,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: title, style: AppText.bodyStrong),
            TextSpan(text: '\n$body', style: AppText.bodySm),
          ],
        ),
      ),
    );
  }
}

class _ChildHeader extends StatelessWidget {
  const _ChildHeader({
    required this.initials,
    required this.background,
    required this.name,
    required this.age,
    required this.meta,
  });

  final String initials;
  final Color background;
  final String name;
  final String age;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NuriAvatar(
          initials: initials,
          size: 52,
          background: background,
          color: AppColors.ink,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.h3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tag(text: age),
                ],
              ),
              const SizedBox(height: 3),
              Text(meta, style: AppText.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.trend,
    this.trendColor = AppColors.brand,
  });

  final String label;
  final String value;
  final String trend;
  final Color trendColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppText.label.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppText.h3),
          const SizedBox(height: 2),
          Text(
            trend,
            style: AppText.caption.copyWith(color: trendColor),
          ),
        ],
      ),
    );
  }
}

class _FlowTile extends StatelessWidget {
  const _FlowTile({
    required this.number,
    required this.title,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String number;
  final String title;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: color, size: 38, radius: 12),
              const Spacer(),
              Text(
                number,
                style: AppText.h2.copyWith(color: AppColors.inkFaint),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: AppText.title.copyWith(fontSize: 14)),
          const SizedBox(height: 2),
          Text(caption, style: AppText.caption),
        ],
      ),
    );
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

// ---------------------------------------------------------------------------
// Utilitas.
// ---------------------------------------------------------------------------

String _initials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String _pct(int value, int total) {
  if (total == 0) return '0%';
  return '${((value / total) * 100).round()}%';
}

Color _statusColor(GrowthStatus status) {
  switch (status) {
    case GrowthStatus.normal:
      return AppColors.statusNormal;
    case GrowthStatus.pendek:
      return AppColors.statusPendek;
    case GrowthStatus.sangatPendek:
      return AppColors.statusSangatPendek;
    case GrowthStatus.tinggi:
      return AppColors.statusTinggi;
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

String _formatDateTime(DateTime date) =>
    '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';
