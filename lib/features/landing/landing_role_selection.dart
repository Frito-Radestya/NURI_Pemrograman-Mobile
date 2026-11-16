import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models.dart';
import 'landing_models.dart';

class LandingRoleSelectionPage extends StatelessWidget {
  const LandingRoleSelectionPage({
    super.key,
    required this.selectedRole,
    required this.onSelectRole,
    required this.onConfirmRole,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onSelectRole;
  final VoidCallback onConfirmRole;

  @override
  Widget build(BuildContext context) {
    final bool isMother = selectedRole == UserRole.mother;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: TweenAnimationBuilder<double>(
        key: const ValueKey('role_page_anim'),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) {
          return Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - val) * 14),
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: LandingColors.leafGreen.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                '04 — PILIH PERAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: LandingColors.forestGreen,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mulai Perjalanan Bersama NURI',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: LandingColors.deepGreen,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih peran untuk mendapatkan pengalaman aplikasi yang sesuai kebutuhanmu.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: LandingColors.charcoal.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 18),

            // Card 1: Saya Ibu / Keluarga
            LandingRoleCard(
              role: UserRole.mother,
              title: 'Saya Ibu / Keluarga',
              subtitle: 'Pantau grafik pertumbuhan standar WHO, catat makanan harian, dan cek kecukupan nutrisi anak.',
              iconWidget: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LandingColors.leafGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/images/nuri_logo_mark.png',
                  fit: BoxFit.contain,
                ),
              ),
              isSelected: selectedRole == UserRole.mother,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelectRole(UserRole.mother);
              },
            ),
            const SizedBox(height: 12),

            // Card 2: Saya Kader Posyandu
            LandingRoleCard(
              role: UserRole.cadre,
              title: 'Saya Kader Posyandu',
              subtitle: 'Catat pengukuran antropometri balita, skrining cepat risiko stunting, dan kelola data Posyandu.',
              iconWidget: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LandingColors.leafGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: LandingColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              isSelected: selectedRole == UserRole.cadre,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelectRole(UserRole.cadre);
              },
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LandingColors.forestGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: onConfirmRole,
                child: Text(
                  isMother
                      ? 'Lanjutkan sebagai Ibu / Keluarga →'
                      : 'Lanjutkan sebagai Kader Posyandu →',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LandingRoleCard extends StatelessWidget {
  const LandingRoleCard({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    required this.isSelected,
    required this.onTap,
  });

  final UserRole role;
  final String title;
  final String subtitle;
  final Widget iconWidget;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? LandingColors.forestGreen
                : LandingColors.forestGreen.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: LandingColors.forestGreen.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: LandingColors.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: LandingColors.charcoal.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? LandingColors.forestGreen
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? LandingColors.forestGreen
                      : const Color(0xFFBFCABA),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
