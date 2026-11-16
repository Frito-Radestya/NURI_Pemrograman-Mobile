import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import 'consultation_widgets.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  static const _nakesList = [
    NakesItem(
      name: 'Bidan Siti Aminah, S.Tr.Keb',
      role: 'Bidan Desa & Pembina Posyandu',
      facility: 'Pustu Sukamaju • Wilayah Posyandu Melati II',
      specialty: 'Pemeriksaan Kehamilan (ANC), Rujukan USG, Stunting Balita',
      status: 'Siap Konsultasi',
      isReady: true,
      schedule: 'Senin–Jumat • 08:00–16:00',
      whatsapp: '6281234567890',
      phone: '(061) 821-1234',
    ),
    NakesItem(
      name: 'Bidan Ratna Dewi, A.Md.Keb',
      role: 'Bidan Praktik Mandiri (BPM)',
      facility: 'Klinik Bersalin Pratama Sukamaju',
      specialty: 'Pemantauan Denyut Janin, Konseling ASI & Imunisasi',
      status: 'Siap Konsultasi',
      isReady: true,
      schedule: 'Praktik Sore • 16:00–20:30',
      whatsapp: '6281298765432',
      phone: '(061) 821-5678',
    ),
    NakesItem(
      name: 'Ns. Hendra Pratama, S.Kep',
      role: 'Perawat Komunitas & Gizi',
      facility: 'Puskesmas Sukamaju Induk',
      specialty: 'Intervensi Gizi Kurang, PMT Balita, Skrining KEK Ibu Hamil',
      status: 'Jadwal Piket',
      isReady: false,
      schedule: 'Senin–Sabtu • 08:00–14:00',
      whatsapp: '6281355556666',
      phone: '(061) 821-9999',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurvedHeader(
              borderRadius: 32,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + 16,
                16,
                22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      const NuriLogo(compact: true, onDark: true),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.support_agent_rounded,
                              size: 13,
                              color: AppColors.secondaryFixed,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Nakes Resmi',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tanya Bidan & Nakes',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bidan dan perawat resmi wilayah Posyandu & Puskesmas binaan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surfaceContainerLow,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryContainer,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.onSecondaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dampingan Langsung Bidan & Nakes',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Bila hasil skrining pertumbuhan atau nutrisi menunjukkan status "Perlu perhatian", Ibu dapat berkonsultasi langsung dengan bidan pembina.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bidan & Perawat Wilayah Anda',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._nakesList.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NakesCard(item: item),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
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
                                color: AppColors.surfaceContainerLow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
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
                                    'Alur Rujukan ke Puskesmas',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    'Standar rujukan KIA Kemenkes RI',
                                    style: TextStyle(
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
                        const Divider(),
                        const SizedBox(height: 10),
                        const ConsultationStepRow(
                          number: '1',
                          text: 'Bawa Buku KIA (Kesehatan Ibu dan Anak) dan KTP/BPJS.',
                        ),
                        const SizedBox(height: 8),
                        const ConsultationStepRow(
                          number: '2',
                          text: 'Tunjukkan hasil catatan pengukuran atau skrining dari aplikasi NURI kepada petugas di Poli KIA / Poli Gizi.',
                        ),
                        const SizedBox(height: 8),
                        const ConsultationStepRow(
                          number: '3',
                          text: 'Dokter/Bidan Puskesmas akan melakukan validasi konfirmasi, pengukuran ulang, dan pemeriksaan USG / lab bila diperlukan.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
