import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../mother/growth_screens.dart';
import 'add_target_screen.dart';
import 'roster_sheets.dart';
import 'roster_widgets.dart';
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

    final balitaCount = myRoster
        .where((r) => r.type == RosterType.child)
        .length;
    final bumilCount = myRoster
        .where((r) => r.type == RosterType.pregnant)
        .length;
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
                              fontWeight: alertCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: alertCount > 0
                                  ? AppColors.red
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$alertCount Kasus',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: alertCount > 0
                                  ? AppColors.red
                                  : Colors.white,
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
                          MaterialPageRoute(builder: (_) => const ScanScreen()),
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
              RosterFilterChip(
                label: 'Semua',
                count: myRoster.length,
                selected: _filter == _RosterFilter.all,
                onTap: () => setState(() => _filter = _RosterFilter.all),
              ),
              const SizedBox(width: 7),
              RosterFilterChip(
                label: 'Balita',
                count: balitaCount,
                selected: _filter == _RosterFilter.child,
                onTap: () => setState(() => _filter = _RosterFilter.child),
              ),
              const SizedBox(width: 7),
              RosterFilterChip(
                label: 'Ibu Hamil',
                count: bumilCount,
                selected: _filter == _RosterFilter.pregnant,
                onTap: () => setState(() => _filter = _RosterFilter.pregnant),
              ),
              const SizedBox(width: 7),
              RosterFilterChip(
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
                  itemBuilder: (context, index) => RosterTile(
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
      builder: (sheetContext) => RosterDetailSheet(
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
      builder: (_) => PregnancyCheckupSheet(entry: entry),
    );
  }

  Future<void> _showFollowUpSheet(
    BuildContext context,
    RosterEntry entry,
  ) async {
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => QuickFollowUpSheet(entry: entry),
    );
  }
}
