import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class AncTile extends StatelessWidget {
  const AncTile({
    super.key,
    required this.index,
    required this.title,
    required this.period,
    required this.description,
    required this.visit,
  });

  final int index;
  final String title;
  final String period;
  final String description;
  final AncVisit? visit;

  @override
  Widget build(BuildContext context) {
    final done = visit != null;
    return AppCard(
      padding: const EdgeInsets.all(13),
      color: done ? AppColors.surface : AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.mint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Pill(
                      label: done ? 'Tercatat' : period,
                      background: done
                          ? AppColors.mint
                          : AppColors.surfaceSubtle,
                      foreground: done ? AppColors.primary : AppColors.muted,
                      fontSize: 11,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                if (done) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${formatDateId(visit!.date)} • ${visit!.facility ?? 'Fasilitas kesehatan'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AncUsgScheduleCard extends StatelessWidget {
  const AncUsgScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skrining USG Kehamilan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Standar Kemenkes RI: Minimal 2x oleh Dokter',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const AncUsgMilestoneTile(
            number: '1',
            trimester: 'Trimester 1 (< 12 minggu)',
            title: 'Skrining Awal & Deteksi Dini',
            description: 'Menentukan kepastian HPL, lokasi kehamilan dalam rahim, jumlah janin, dan denyut jantung janin.',
          ),
          const SizedBox(height: 10),
          const AncUsgMilestoneTile(
            number: '2',
            trimester: 'Trimester 3 (32–36 minggu)',
            title: 'Skrining Kesiapan Persalinan',
            description: 'Menilai pertumbuhan janin, perkiraan berat lahir (cegah BBLR/stunting), posisi plasenta, dan kecukupan air ketuban.',
          ),
        ],
      ),
    );
  }
}

class AncUsgMilestoneTile extends StatelessWidget {
  const AncUsgMilestoneTile({
    super.key,
    required this.number,
    required this.trimester,
    required this.title,
    required this.description,
  });

  final String number;
  final String trimester;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trimester,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
