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
import '../../data/nuri_repository.dart' show ScreeningRecord;
import '../../domain/models/child.dart';
import '../../domain/models/growth_status.dart';
import '../../state/app_state.dart';

/// Daftar sasaran balita Posyandu (pencarian, filter, dan kartu anak).
class KaderTargetsScreen extends StatefulWidget {
  const KaderTargetsScreen({super.key});

  @override
  State<KaderTargetsScreen> createState() => _KaderTargetsScreenState();
}

class _KaderTargetsScreenState extends State<KaderTargetsScreen> {
  String _query = '';
  int _filter = 0; // 0 = semua, 1 = butuh perhatian

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final String nama = state.user?.displayName ?? 'Kader';
    final List<Child> all = state.children;

    final session = state.activeSession;
    final int hadir = session == null
        ? 0
        : state.screeningsInSession(session.id).length;
    final int total = all.length;
    final double persen = total == 0 ? 0 : (hadir / total).clamp(0.0, 1.0);

    final List<Child> butuhPerhatian = all.where((Child child) {
      final ScreeningRecord? record = state.latestScreening(child.id);
      return record != null && record.result.status.needsFollowUp;
    }).toList();

    final String q = _query.trim().toLowerCase();
    final List<Child> filtered = all.where((Child child) {
      final bool needs = state.latestScreening(child.id)?.result.status
              .needsFollowUp ??
          false;
      if (_filter == 1 && !needs) return false;
      if (q.isEmpty) return true;
      return child.nickname.toLowerCase().contains(q);
    }).toList();

    return NuriScaffold(
      bottomNavigationBar: const KaderTabBar(active: '/kader-targets'),
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
          const Text('Daftar Sasaran Balita', style: AppText.h1),
          const SizedBox(height: 6),
          Text(
            '${state.user?.posyanduName ?? 'Posyandu Melati'}  •  '
            '$total Balita Terdaftar',
            style: AppText.body,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              NuriSecondaryButton(
                label: 'Sync',
                icon: Icons.sync_rounded,
                filled: true,
                expand: false,
                onPressed: () => _sync(context),
              ),
              NuriSecondaryButton(
                label: _filter == 0 ? 'Filter' : 'Butuh Perhatian',
                icon: Icons.tune_rounded,
                filled: true,
                expand: false,
                onPressed: () =>
                    setState(() => _filter = _filter == 0 ? 1 : 0),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Pelaksanaan.
          NuriCard(
            color: AppColors.canvasGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Pelaksanaan Posyandu',
                        style: AppText.h3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tag(text: '${(persen * 100).round()}% Selesai'),
                  ],
                ),
                const SizedBox(height: 6),
                Text('$hadir dari $total ditimbang', style: AppText.bodySm),
                const SizedBox(height: 14),
                NutrientBar(value: persen),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _LegendDot(
                      color: AppColors.brand,
                      text: '$hadir Hadir',
                    ),
                    _LegendDot(
                      color: AppColors.accent,
                      text: '${butuhPerhatian.length} Perlu Pemantauan',
                    ),
                    _LegendDot(
                      color: AppColors.lineStrong,
                      text: '${(total - hadir).clamp(0, total)} Belum Datang',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pencarian.
          TextField(
            onChanged: (String value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Cari nama balita…',
              hintStyle: AppText.bodySm,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.inkFaint,
              ),
              filled: true,
              fillColor: AppColors.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.brand),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('• ${filtered.length} Balita ditampilkan', style: AppText.caption),
          const SizedBox(height: 14),

          // Filter chips.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua ($total)',
                  active: _filter == 0,
                  onTap: () => setState(() => _filter = 0),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '● Butuh Perhatian (${butuhPerhatian.length})',
                  active: _filter == 1,
                  onTap: () => setState(() => _filter = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            const NoteBox(
              background: AppColors.surfaceSoft,
              icon: Icons.search_off_rounded,
              child: Text(
                'Tidak ada balita yang cocok dengan pencarian atau filter ini.',
                style: AppText.bodySm,
              ),
            )
          else
            for (final Child child in filtered) ...[
              _ChildTargetCard(
                child: child,
                record: state.latestScreening(child.id),
                today: state.today,
                onTap: () {
                  state.selectChild(child.id);
                  context.go('/kader-target-detail');
                },
              ),
              const SizedBox(height: 12),
            ],

          const SizedBox(height: 6),
          const NoteBox(
            background: AppColors.pastelGreenSoft,
            icon: Icons.tips_and_updates_outlined,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Tips Kader Pendamping',
                    style: AppText.bodyStrong,
                  ),
                  TextSpan(
                    text:
                        '\nGunakan bahasa yang merangkul dan memotivasi tentang '
                        'pentingnya pemenuhan gizi berimbang. Hindari memberi '
                        'label "anak stunting" secara langsung di depan umum. '
                        '#SahabatBunda',
                    style: AppText.bodySm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sync(BuildContext context) async {
    final NuriAppState state = NuriScope.read(context);
    final int sent = await state.sync();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent == 0
              ? 'Semua data sudah tersinkron.'
              : '$sent data berhasil disinkronkan.',
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian lokal.
// ---------------------------------------------------------------------------

class _ChildTargetCard extends StatelessWidget {
  const _ChildTargetCard({
    required this.child,
    required this.record,
    required this.today,
    required this.onTap,
  });

  final Child child;
  final ScreeningRecord? record;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final GrowthStatus? status = record?.result.status;
    final Color border = status == null
        ? AppColors.line
        : (status.needsFollowUp ? _statusSoft(status) : AppColors.pastelGreen);

    return NuriCard(
      border: border,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChildHeader(
            initials: _initials(child.nickname),
            background:
                status == null ? AppColors.pastelBlue : _statusSoft(status),
            name: child.nickname,
            meta:
                '${child.ageLabelAt(today)} • ${child.sex.label} • '
                '${child.posyanduName ?? 'Posyandu Melati'}',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tag(
                text: child.sex.label,
                color: child.sex.label == 'Perempuan'
                    ? AppColors.pastelPurple
                    : AppColors.pastelBlue,
              ),
              Tag(
                text: child.consent == null ? 'Belum ada consent' : 'Terverifikasi',
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (record == null)
            const _Banner(
              text: 'Belum diukur pada sesi ini',
              color: AppColors.pastelPeach,
              dotColor: AppColors.accent,
            )
          else
            _Banner(
              text: status!.needsFollowUp
                  ? 'Butuh Pendampingan Khusus'
                  : 'Tumbuh Optimal (${status.label})',
              color: _statusSoft(status),
              dotColor: _statusColor(status),
            ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ChildMetric(
                  label: 'Berat Badan',
                  value: record == null
                      ? '-'
                      : '${record!.measurement.weightKg.toStringAsFixed(1)} kg',
                  caption: record == null
                      ? 'Belum ada data'
                      : 'Diukur ${_formatDate(record!.measurement.measuredOn)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChildMetric(
                  label: 'Tinggi Badan',
                  value: record == null
                      ? '-'
                      : '${record!.measurement.lengthHeightCm.toStringAsFixed(1)} cm',
                  caption: record == null
                      ? 'Belum ada data'
                      : '${record!.result.ageMonths} bulan',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (record != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(
                  text: 'Z-Score TB/U: ${record!.result.zLabel} SD '
                      '(${record!.result.status.label})',
                  color: _statusSoft(record!.result.status),
                ),
                StatusChip(
                  text: record!.result.status.needsFollowUp
                      ? 'Rujukan PKM'
                      : 'Pantau Tumbuh',
                  color: AppColors.pastelGreen,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: AppText.caption.copyWith(color: AppColors.inkSoft)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.brand : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: active ? null : Border.all(color: AppColors.line),
          ),
          child: Text(
            label,
            style: AppText.bodySm.copyWith(
              color: active ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    required this.meta,
  });

  final String initials;
  final Color background;
  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.h3,
              ),
              const SizedBox(height: 3),
              Text(meta, style: AppText.caption),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.inkFaint),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.text,
    required this.color,
    this.dotColor = AppColors.statusSangatPendek,
  });

  final String text;
  final Color color;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppText.bodyStrong.copyWith(fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}

class _ChildMetric extends StatelessWidget {
  const _ChildMetric({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 2),
        Text(value, style: AppText.title.copyWith(fontSize: 14.5)),
        const SizedBox(height: 2),
        Text(caption, style: AppText.caption),
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
