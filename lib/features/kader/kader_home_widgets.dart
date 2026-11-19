import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class KaderQuickMenu extends StatelessWidget {
  const KaderQuickMenu({
    super.key,
    required this.onRoster,
    required this.onAddTarget,
    required this.onScan,
    required this.onFollowUp,
    required this.onNakes,
  });

  final VoidCallback onRoster;
  final VoidCallback onAddTarget;
  final VoidCallback onScan;
  final VoidCallback onFollowUp;
  final VoidCallback onNakes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu Cepat Kader',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Alat Sesi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _KaderMenuItem(
              icon: Icons.groups_rounded,
              label: 'Daftar Sasaran',
              onTap: onRoster,
            ),
            _KaderMenuItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan QR KMS',
              isHighlight: true,
              onTap: onScan,
            ),
            _KaderMenuItem(
              icon: Icons.person_add_rounded,
              label: 'Tambah Sasaran',
              onTap: onAddTarget,
            ),
            _KaderMenuItem(
              icon: Icons.support_agent_rounded,
              label: 'Atur Bidan',
              onTap: onNakes,
            ),
          ],
        ),
      ],
    );
  }
}

class _KaderMenuItem extends StatelessWidget {
  const _KaderMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isHighlight ? AppGradients.button : null,
                color: isHighlight ? null : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isHighlight ? AppShadows.glow : null,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isHighlight ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                color: isHighlight ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KaderSyncButton extends StatelessWidget {
  const KaderSyncButton({
    super.key,
    required this.pending,
    required this.onTap,
  });

  final int pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              pending == 0
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_upload_outlined,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              pending == 0 ? 'Tersinkron' : '$pending Tertunda',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KaderSessionCard extends StatelessWidget {
  const KaderSessionCard({
    super.key,
    required this.session,
    required this.posyanduName,
    required this.present,
    required this.target,
    required this.followUpCount,
    required this.onMeasure,
    required this.onComplete,
  });

  final PosyanduSession? session;
  final String posyanduName;
  final int present;
  final int target;
  final int followUpCount;
  final VoidCallback onMeasure;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : (present / target).clamp(0.0, 1.0);
    final done = session?.isDone ?? false;
    final hasSession = session != null;
    final percentInt = (progress * 100).round();
    final notPresent = (target - present).clamp(0, target);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SESI PENIMBANGAN RUTIN',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      session?.posyanduName ??
                          (posyanduName.isEmpty
                              ? 'Posyandu Anda'
                              : posyanduName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: !hasSession
                      ? AppColors.surfaceContainerLow
                      : (done
                            ? AppColors.amberSoft
                            : AppColors.secondaryContainer),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: !hasSession
                            ? AppColors.muted
                            : (done ? AppColors.amber : AppColors.primary),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      !hasSession
                          ? 'Belum ada sesi'
                          : (done ? 'SESI SELESAI' : 'SESI BERLANGSUNG'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: !hasSession
                            ? AppColors.muted
                            : (done
                                  ? AppColors.amber
                                  : AppColors.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cakupan Kehadiran (D/S)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: '$present',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                            children: [
                              TextSpan(
                                text: ' / $target Balita Sasaran',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percentInt%',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                        const Text(
                          'Target 85%',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 8,
                    color: AppColors.surfaceContainerHigh,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondaryFixedDim,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (followUpCount > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            size: 15,
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$followUpCount Butuh Tindak Lanjut',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Semua terpantau',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    Text(
                      '$notPresent Belum Hadir',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: present == 0
                ? '+ Mulai Scan / Ukur Baru'
                : '+ Lanjut Scan / Ukur',
            icon: Icons.add_a_photo_rounded,
            height: 48,
            onPressed: done ? null : onMeasure,
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.lock_reset_rounded, size: 17),
                label: const Text(
                  'Kunci & Selesaikan Rekap Sesi',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
