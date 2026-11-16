import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class NakesItem {
  const NakesItem({
    required this.name,
    required this.role,
    required this.facility,
    required this.specialty,
    required this.status,
    required this.isReady,
    required this.schedule,
    required this.whatsapp,
    required this.phone,
  });

  final String name;
  final String role;
  final String facility;
  final String specialty;
  final String status;
  final bool isReady;
  final String schedule;
  final String whatsapp;
  final String phone;
}

class NakesCard extends StatelessWidget {
  const NakesCard({super.key, required this.item});

  final NakesItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(name: item.name, size: 46, index: item.name.length % 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: item.isReady
                                ? AppColors.secondaryContainer
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: item.isReady
                                      ? AppColors.primary
                                      : AppColors.muted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.status,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: item.isReady
                                      ? AppColors.onSecondaryContainer
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.role,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.facility,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.medical_information_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.specialty,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 5),
              Text(
                item.schedule,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showNuriSnack(
                        context,
                        'Membuka konsultasi WhatsApp dengan ${item.name}…',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text(
                      'Chat WhatsApp',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showNuriSnack(
                      context,
                      'Menghubungi nomor telepon fasilitas: ${item.phone}',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  icon: const Icon(Icons.phone_rounded, size: 15),
                  label: const Text(
                    'Telepon',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConsultationStepRow extends StatelessWidget {
  const ConsultationStepRow({
    super.key,
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
