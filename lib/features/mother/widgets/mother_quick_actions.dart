import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class MotherQuickActions extends StatelessWidget {
  const MotherQuickActions({
    super.key,
    required this.onDiary,
    required this.onCamera,
    required this.onAnc,
    required this.onConsultation,
  });

  final VoidCallback onDiary;
  final VoidCallback onCamera;
  final VoidCallback onAnc;
  final VoidCallback onConsultation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat Bunda',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Buku Makan',
              isPrimary: true,
              onTap: onDiary,
            ),
            _QuickActionItem(
              icon: Icons.document_scanner_rounded,
              label: 'Foto Piring',
              isPrimary: true,
              onTap: onCamera,
            ),
            _QuickActionItem(
              icon: Icons.event_available_rounded,
              label: 'Jadwal ANC',
              isPrimary: true,
              onTap: onAnc,
            ),
            _QuickActionItem(
              icon: Icons.support_agent_rounded,
              label: 'Tanya Bidan',
              isPrimary: true,
              onTap: onConsultation,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: isPrimary ? AppGradients.button : null,
              color: isPrimary ? null : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isPrimary ? AppShadows.glow : null,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isPrimary ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              color: isPrimary ? AppColors.primary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
