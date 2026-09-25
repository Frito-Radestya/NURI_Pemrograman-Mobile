import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const AppSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade400, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ),
              if (onFilterTap != null)
                InkWell(
                  onTap: onFilterTap,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.tune, size: 20),
                  ),
                )
              else
                Icon(Icons.tune, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileGreeting extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String? roleTitle;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileTap;

  const ProfileGreeting({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.roleTitle,
    this.onLogout,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Halo, ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  if (roleTitle != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        roleTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Keluar Akun',
            onPressed: onLogout,
          ),
        GestureDetector(
          onTap: onProfileTap,
          child: Tooltip(
            message: 'Buka profil dan pengaturan',
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.white24,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}
