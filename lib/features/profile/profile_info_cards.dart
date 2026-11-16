import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class ProfileFamilyCodeCard extends StatelessWidget {
  const ProfileFamilyCodeCard({
    super.key,
    required this.child,
    required this.pregnancy,
    required this.onShow,
    required this.onClaim,
  });

  final Child? child;
  final Pregnancy? pregnancy;
  final VoidCallback onShow;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final subject =
        child?.nickname ?? (pregnancy != null ? 'Kehamilan' : 'Keluarga');
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 22,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koneksi Keluarga & Posyandu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Buat QR izin akses untuk $subject (sekali pakai, 24 jam)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onShow,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Buat QR'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          InkWell(
            onTap: onClaim,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.vpn_key_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Punya kode klaim anak dari Kader Posyandu? Masukkan di sini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePosyanduCard extends StatelessWidget {
  const ProfilePosyanduCard({
    super.key,
    required this.name,
    required this.area,
    required this.target,
    required this.onQr,
  });

  final String name;
  final String area;
  final int target;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  size: 21,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      area,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Pill(label: '$target sasaran', fontSize: 11.5),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onQr,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.qr_code_2_rounded, size: 17),
              label: const Text('Tampilkan Kode Posyandu'),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSyncCard extends StatelessWidget {
  const ProfileSyncCard({
    super.key,
    required this.pending,
    required this.lastSyncAt,
    required this.onSync,
  });

  final int pending;
  final DateTime? lastSyncAt;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(
            pending == 0
                ? Icons.cloud_done_rounded
                : Icons.cloud_upload_outlined,
            size: 24,
            color: pending == 0 ? AppColors.primary : AppColors.amber,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pending == 0
                      ? 'Semua data tersinkron'
                      : '$pending perubahan tertunda',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  lastSyncAt == null
                      ? 'Belum pernah sinkron'
                      : 'Terakhir ${formatDateId(lastSyncAt!, withYear: false)} ${formatTime(lastSyncAt!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSync,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text('Sinkron'),
          ),
        ],
      ),
    );
  }
}

class ProfilePrivacyCard extends StatelessWidget {
  const ProfilePrivacyCard({
    super.key,
    required this.grants,
    required this.onRevoke,
  });

  final List<AccessGrant> grants;
  final ValueChanged<AccessGrant> onRevoke;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 19, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Akses yang kamu berikan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Kader hanya dapat mengakses data yang diizinkan. Cabut kapan saja.',
            style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 10),
          if (grants.isEmpty)
            const Text(
              'Belum ada akses aktif.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            )
          else
            ...grants.map(
              (grant) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              grant.granteeName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${grant.subjectName} • ${grant.scopes.join(', ')}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (grant.status == 'aktif')
                        TextButton(
                          onPressed: () => onRevoke(grant),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.red,
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: const Text('Cabut'),
                        )
                      else
                        const Pill(
                          label: 'Dicabut',
                          background: AppColors.redSoft,
                          foreground: AppColors.red,
                          fontSize: 11,
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
