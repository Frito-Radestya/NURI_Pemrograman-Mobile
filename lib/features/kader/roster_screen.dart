import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../mother/growth_screens.dart';
import 'add_target_screen.dart';
import 'scan_screen.dart';

enum _RosterFilter { all, child, pregnant, followUp }

class RosterScreen extends ConsumerStatefulWidget {
  const RosterScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends ConsumerState<RosterScreen> {
  final _search = TextEditingController();
  _RosterFilter _filter = _RosterFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<RosterEntry> _visible(List<RosterEntry> source) {
    final query = _search.text.trim().toLowerCase();
    final list = source.where((entry) {
      final matchesFilter = switch (_filter) {
        _RosterFilter.all => true,
        _RosterFilter.child => entry.type == RosterType.child,
        _RosterFilter.pregnant => entry.type == RosterType.pregnant,
        _RosterFilter.followUp => entry.needsFollowUp,
      };
      final matchesQuery =
          query.isEmpty ||
          entry.name.toLowerCase().contains(query) ||
          entry.guardianName.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
    list.sort((a, b) {
      if (a.priority != b.priority) return a.priority ? -1 : 1;
      if (a.attendance != b.attendance) {
        final order = {
          AttendanceStatus.absent: 0,
          AttendanceStatus.waiting: 1,
          AttendanceStatus.present: 2,
        };
        return (order[a.attendance] ?? 0).compareTo(order[b.attendance] ?? 0);
      }
      return a.name.compareTo(b.name);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final myRoster = state.myRoster;
    final entries = _visible(myRoster);
    final present = myRoster
        .where((r) => r.attendance == AttendanceStatus.present)
        .length;

    final balitaCount =
        myRoster.where((r) => r.type == RosterType.child).length;
    final bumilCount =
        myRoster.where((r) => r.type == RosterType.pregnant).length;
    final alertCount = myRoster.where((r) => r.needsFollowUp).length;
    final notPresent = myRoster.length - present;

    final content = Column(
      children: [
        // Top Curved Organic Header (Inspired by UI_UX/nuri_roster_sasaran_kader)
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
                              Icons.shield_outlined,
                              size: 13,
                              color: AppColors.secondaryFixed,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Kader',
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddTargetScreen(),
                      ),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Roster Sasaran',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${state.posyanduName} • $balitaCount Balita & $bumilCount Bumil',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              // Bento Stats Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Sasaran',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${myRoster.length}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kehadiran',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              text: '$present',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondaryFixed,
                              ),
                              children: [
                                TextSpan(
                                  text: ' / $notPresent blm',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: alertCount > 0
                            ? AppColors.redSoft.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perlu Tindak',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: alertCount > 0 ? FontWeight.w700 : FontWeight.normal,
                              color: alertCount > 0 ? AppColors.red : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$alertCount Kasus',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: alertCount > 0 ? AppColors.red : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search & Scan Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 14, right: 6),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 13.5),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama anak, ibu, atau NIK…',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 11),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                    if (_search.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ScanScreen(),
                          ),
                        ),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _FilterChip(
                label: 'Semua',
                count: myRoster.length,
                selected: _filter == _RosterFilter.all,
                onTap: () => setState(() => _filter = _RosterFilter.all),
              ),
              const SizedBox(width: 7),
              _FilterChip(
                label: 'Balita',
                count: balitaCount,
                selected: _filter == _RosterFilter.child,
                onTap: () => setState(() => _filter = _RosterFilter.child),
              ),
              const SizedBox(width: 7),
              _FilterChip(
                label: 'Ibu Hamil',
                count: bumilCount,
                selected: _filter == _RosterFilter.pregnant,
                onTap: () => setState(() => _filter = _RosterFilter.pregnant),
              ),
              const SizedBox(width: 7),
              _FilterChip(
                label: 'Butuh Tindak',
                count: alertCount,
                selected: _filter == _RosterFilter.followUp,
                isAlert: true,
                onTap: () => setState(() => _filter = _RosterFilter.followUp),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: entries.isEmpty
              ? const EmptyState(
                  title: 'Sasaran tidak ditemukan',
                  body: 'Coba kata kunci lain atau ubah filter.',
                  icon: Icons.search_off_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) => _RosterTile(
                    entry: entries[index],
                    onTap: () => _showEntrySheet(context, entries[index]),
                  ),
                ),
        ),
      ],
    );

    if (widget.embedded) return content;
    return Scaffold(backgroundColor: AppColors.background, body: content);
  }

  Future<void> _showEntrySheet(BuildContext context, RosterEntry entry) async {
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => _RosterDetailSheet(
        entry: entry,
        onMeasure: () {
          Navigator.of(sheetContext).pop();
          final childId = entry.subjectId;
          if (childId == null) {
            showNuriSnack(
              context,
              'Data anak belum terhubung. Tambahkan sasaran baru.',
              error: true,
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  MeasurementInputScreen(childId: childId, isCadre: true),
            ),
          );
        },
        onCheckup: () {
          Navigator.of(sheetContext).pop();
          _showCheckupSheet(context, entry);
        },
        onFollowUp: () {
          Navigator.of(sheetContext).pop();
          _showFollowUpSheet(context, entry);
        },
      ),
    );
  }

  Future<void> _showCheckupSheet(
    BuildContext context,
    RosterEntry entry,
  ) async {
    await showNuriSheet<void>(
      context: context,
      builder: (_) => _PregnancyCheckupSheet(entry: entry),
    );
  }

  Future<void> _showFollowUpSheet(
    BuildContext context,
    RosterEntry entry,
  ) async {
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => _QuickFollowUpSheet(entry: entry),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.isAlert = false,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Gradient? gradient;

    if (selected) {
      if (isAlert) {
        bg = AppColors.red;
        fg = Colors.white;
      } else {
        bg = AppColors.primary;
        fg = Colors.white;
        gradient = AppGradients.button;
      }
    } else {
      if (isAlert) {
        bg = AppColors.redSoft;
        fg = AppColors.red;
      } else {
        bg = AppColors.surfaceContainerLow;
        fg = AppColors.onSurfaceVariant;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: gradient == null ? bg : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: selected ? AppShadows.glow : null,
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _RosterTile extends StatelessWidget {
  const _RosterTile({required this.entry, required this.onTap});

  final RosterEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPregnant = entry.type == RosterType.pregnant;
    final stripeColor = entry.needsFollowUp
        ? AppColors.red
        : (entry.attendance == AttendanceStatus.present
            ? AppColors.primary
            : AppColors.outlineVariant);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(color: stripeColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        name: entry.name,
                        index: entry.avatarIndex,
                        size: 44,
                      ),
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
                                      fontFamily: 'Nunito',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
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
                              isPregnant
                                  ? '${entry.pregnancyWeeks ?? '—'} minggu • ${entry.guardianName}'
                                  : '${entry.ageMonths ?? '—'} bulan • Ibu: ${entry.guardianName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isPregnant)
                        const Pill(
                          label: 'Bumil',
                          icon: Icons.pregnant_woman_rounded,
                          background: AppColors.purpleSoft,
                          foreground: AppColors.purple,
                          fontSize: 11,
                        )
                      else if (entry.category != null)
                        GrowthStatusBadge(
                          category: entry.category!,
                          compact: true,
                        )
                      else
                        const Pill(label: 'Belum diukur', fontSize: 11),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        entry.attendance == AttendanceStatus.present
                            ? Icons.check_circle_rounded
                            : entry.attendance == AttendanceStatus.absent
                                ? Icons.cancel_rounded
                                : Icons.schedule_rounded,
                        size: 15,
                        color: entry.attendance == AttendanceStatus.present
                            ? AppColors.primary
                            : entry.attendance == AttendanceStatus.absent
                                ? AppColors.red
                                : AppColors.amber,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        entry.attendance.label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: entry.attendance == AttendanceStatus.present
                              ? AppColors.primary
                              : entry.attendance == AttendanceStatus.absent
                                  ? AppColors.red
                                  : AppColors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.reason ?? entry.guardianName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      if (entry.pendingSync) const SyncBadge(pending: true),
                    ],
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

class _RosterDetailSheet extends ConsumerWidget {
  const _RosterDetailSheet({
    required this.entry,
    required this.onMeasure,
    required this.onCheckup,
    required this.onFollowUp,
  });

  final RosterEntry entry;
  final VoidCallback onMeasure;
  final VoidCallback onCheckup;
  final VoidCallback onFollowUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPregnant = entry.type == RosterType.pregnant;
    final latest = entry.lastMeasuredAt;
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
                      isPregnant
                          ? 'Ibu hamil ${entry.pregnancyWeeks ?? '—'} minggu'
                          : '${entry.ageMonths ?? '—'} bulan • ${entry.sex?.label ?? 'Balita'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.category != null)
                GrowthStatusBadge(category: entry.category!),
            ],
          ),
          const SizedBox(height: 14),
          if (entry.reason != null) ...[
            InfoBanner(
              title: entry.priority ? 'Perlu perhatian' : 'Catatan skrining',
              body: entry.reason,
              icon: entry.priority
                  ? Icons.priority_high_rounded
                  : Icons.info_outline_rounded,
              background: entry.priority ? AppColors.amberSoft : AppColors.mint,
              foreground: entry.priority
                  ? AppColors.amber
                  : AppColors.primaryDark,
            ),
            const SizedBox(height: 14),
          ],
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
                  color: entry.attendance == AttendanceStatus.present
                      ? AppColors.primary
                      : AppColors.amber,
                  background: entry.attendance == AttendanceStatus.present
                      ? AppColors.mint
                      : AppColors.amberSoft,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                NuriInfoRow(
                  icon: Icons.straighten_rounded,
                  title: 'Pengukuran terakhir',
                  subtitle: latest == null
                      ? 'Belum ada'
                      : formatDateId(latest, withYear: false),
                ),
                if (isPregnant) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  NuriInfoRow(
                    icon: Icons.monitor_heart_outlined,
                    title: 'LiLA / Hb',
                    subtitle:
                        '${entry.lilaCm?.toStringAsFixed(1) ?? '—'} cm • '
                        '${entry.hbGdl?.toStringAsFixed(1) ?? '—'} g/dL',
                    color: AppColors.purple,
                    background: AppColors.purpleSoft,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: isPregnant ? 'Catat pemeriksaan ibu hamil' : 'Ukur sekarang',
            icon: isPregnant
                ? Icons.monitor_heart_outlined
                : Icons.straighten_rounded,
            onPressed: isPregnant ? onCheckup : onMeasure,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(appControllerProvider.notifier)
                        .markAttendance(
                          entry.id,
                          entry.attendance == AttendanceStatus.present
                              ? AttendanceStatus.waiting
                              : AttendanceStatus.present,
                        );
                    Navigator.of(context).pop();
                    showNuriSnack(
                      context,
                      entry.attendance == AttendanceStatus.present
                          ? 'Kehadiran diperbarui menjadi menunggu.'
                          : '${entry.name} ditandai hadir.',
                    );
                  },
                  icon: Icon(
                    entry.attendance == AttendanceStatus.present
                        ? Icons.undo_rounded
                        : Icons.check_rounded,
                    size: 18,
                  ),
                  label: Text(
                    entry.attendance == AttendanceStatus.present
                        ? 'Batalkan hadir'
                        : 'Tandai hadir',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFollowUp,
                  icon: const Icon(Icons.follow_the_signs_rounded, size: 18),
                  label: const Text(
                    'Tindak lanjut',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          if (!isPregnant && !entry.linked && entry.subjectId != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final claim = ref
                      .read(appControllerProvider.notifier)
                      .createChildClaimCode(
                        childId: entry.subjectId!,
                        childName: entry.name,
                      );
                  if (claim == null) return;
                  Navigator.of(context).pop();
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Kode Klaim Ibu'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Berikan kode sekali pakai ini kepada Ibu dari ${entry.name} agar profil dan riwayat tumbuh kembang anak berpindah ke akun Ibu (berlaku 7 hari):',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SelectableText(
                              claim.code,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Selesai'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.vpn_key_outlined, size: 18),
                label: const Text('Buat Kode Klaim untuk Ibu (7 hari)'),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const NuriDisclaimer(compact: true),
        ],
      ),
    );
  }
}

class _PregnancyCheckupSheet extends ConsumerStatefulWidget {
  const _PregnancyCheckupSheet({required this.entry});

  final RosterEntry entry;

  @override
  ConsumerState<_PregnancyCheckupSheet> createState() =>
      _PregnancyCheckupSheetState();
}

class _PregnancyCheckupSheetState
    extends ConsumerState<_PregnancyCheckupSheet> {
  final _weight = TextEditingController();
  final _lila = TextEditingController(text: '24,0');
  final _hb = TextEditingController(text: '11,5');

  @override
  void dispose() {
    _weight.dispose();
    _lila.dispose();
    _hb.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  void _save() {
    final lila = _parse(_lila);
    final hb = _parse(_hb);
    if (lila == null || lila < 10 || lila > 40) {
      showNuriSnack(context, 'LiLA harus di antara 10–40 cm.', error: true);
      return;
    }
    if (hb != null && (hb < 5 || hb > 20)) {
      showNuriSnack(context, 'Hb harus di antara 5–20 g/dL.', error: true);
      return;
    }
    ref
        .read(appControllerProvider.notifier)
        .recordPregnancyCheckup(
          rosterId: widget.entry.id,
          lilaCm: lila,
          hbGdl: hb,
          weightKg: _parse(_weight),
        );
    Navigator.of(context).pop();
    showNuriSnack(
      context,
      lila < 23.5 || (hb != null && hb < 11)
          ? 'Pemeriksaan tersimpan. Ibu masuk daftar tindak lanjut.'
          : 'Pemeriksaan ibu hamil tersimpan.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pemeriksaan ibu hamil',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 3),
          Text(
            widget.entry.name,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NuriTextField(
                  label: 'Berat badan (kg)',
                  controller: _weight,
                  hint: '58,5',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NuriTextField(
                  label: 'LiLA (cm)',
                  controller: _lila,
                  hint: '24,0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          NuriTextField(
            label: 'Hb (g/dL) — bila tersedia',
            controller: _hb,
            hint: '11,5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            helper: 'Batas risiko: LiLA < 23,5 cm atau Hb < 11 g/dL.',
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            title: 'Pemeriksaan cepat di sesi',
            body: 'Data tersimpan lokal dan ditandai perlu sinkron. Rujuk ke bidan/faskes bila ada tanda bahaya.',
            icon: Icons.health_and_safety_outlined,
          ),
          const SizedBox(height: 16),
          NuriButton(
            label: 'Simpan pemeriksaan',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _QuickFollowUpSheet extends ConsumerWidget {
  const _QuickFollowUpSheet({required this.entry});

  final RosterEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const options = [
      (
        FollowUpStatus.visited,
        'Sudah dikunjungi',
        Icons.home_outlined,
        AppColors.blue,
        AppColors.blueSoft,
      ),
      (
        FollowUpStatus.referred,
        'Dirujuk ke faskes',
        Icons.local_hospital_outlined,
        AppColors.red,
        AppColors.redSoft,
      ),
      (
        FollowUpStatus.unreachable,
        'Tidak dapat ditemui',
        Icons.person_off_outlined,
        AppColors.amber,
        AppColors.amberSoft,
      ),
      (
        FollowUpStatus.closed,
        'Selesai',
        Icons.task_alt_rounded,
        AppColors.primary,
        AppColors.mint,
      ),
    ];
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
            '${entry.name} • ${entry.reason ?? 'Perlu konfirmasi'}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                onTap: () {
                  ref
                      .read(appControllerProvider.notifier)
                      .recordFollowUp(entry.id, option.$1, note: option.$2);
                  Navigator.of(context).pop();
                  showNuriSnack(
                    context,
                    'Tindak lanjut dicatat: ${option.$2}.',
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: option.$5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(option.$3, size: 19, color: option.$4),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        option.$2,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
