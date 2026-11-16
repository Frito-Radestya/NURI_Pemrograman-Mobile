import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

export 'profile_info_cards.dart';
export 'profile_pregnancy_card.dart';
export 'profile_settings_card.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.user, required this.onEdit});

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      shadow: true,
      child: Row(
        children: [
          AppAvatar(
            name: user.name,
            index: user.role == UserRole.cadre ? 7 : 0,
            imageAsset: user.avatarAsset,
            size: 54,
            showBadge: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
                if (user.authUid != null) ...[
                  const SizedBox(height: 6),
                  const Pill(
                    label: 'Firebase Auth',
                    icon: Icons.verified_user_outlined,
                    fontSize: 11,
                    background: AppColors.softMint,
                    foreground: AppColors.deepForest,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.deepForest,
            ),
            tooltip: 'Ubah nama',
          ),
        ],
      ),
    );
  }
}

class ProfileChildRow extends StatelessWidget {
  const ProfileChildRow({
    super.key,
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final Child child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = child.latestMeasurement;
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      borderColor: selected ? AppColors.primary : AppColors.line,
      child: Row(
        children: [
          AppAvatar(name: child.nickname, index: child.avatarIndex, size: 42),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        child.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${child.ageLabel()} • ${child.sex.label} • ${child.measurements.length} pengukuran',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (latest != null)
            GrowthStatusBadge(category: latest.category, compact: true),
        ],
      ),
    );
  }
}
