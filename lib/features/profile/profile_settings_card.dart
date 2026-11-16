import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    super.key,
    required this.remindersEnabled,
    required this.onToggleReminders,
    required this.onConsultation,
    required this.onDisclaimer,
    required this.onAbout,
  });

  final bool remindersEnabled;
  final ValueChanged<bool> onToggleReminders;
  final VoidCallback onConsultation;
  final VoidCallback onDisclaimer;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: remindersEnabled,
            onChanged: onToggleReminders,
            secondary: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'Pengingat lokal',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'TTD, ANC, ukur bulanan, dan jadwal Posyandu.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.medical_services_outlined,
              color: AppColors.primary,
            ),
            title: const Text(
              'Konsultasi Bidan & Nakes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Daftar bidan dan perawat yang siap mendampingi.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
            onTap: onConsultation,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primary,
            ),
            title: const Text(
              'Disclaimer skrining',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Baca ulang batas penggunaan NURI.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
            onTap: onDisclaimer,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'Tentang NURI',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Versi demo 0.2 • sumber data & lisensi.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
            onTap: onAbout,
          ),
        ],
      ),
    );
  }
}

class ProfileAccountActions extends StatelessWidget {
  const ProfileAccountActions({
    super.key,
    required this.onReset,
    required this.onLogout,
  });

  final VoidCallback onReset;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reset akun'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Keluar'),
          ),
        ),
      ],
    );
  }
}
