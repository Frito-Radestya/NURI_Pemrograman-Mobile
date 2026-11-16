import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class RosterDetailSheet extends ConsumerWidget {
  const RosterDetailSheet({
    super.key,
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

class PregnancyCheckupSheet extends ConsumerStatefulWidget {
  const PregnancyCheckupSheet({super.key, required this.entry});

  final RosterEntry entry;

  @override
  ConsumerState<PregnancyCheckupSheet> createState() =>
      _PregnancyCheckupSheetState();
}

class _PregnancyCheckupSheetState extends ConsumerState<PregnancyCheckupSheet> {
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

class QuickFollowUpSheet extends ConsumerWidget {
  const QuickFollowUpSheet({super.key, required this.entry});

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
