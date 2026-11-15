import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  static const _nakesList = [
    _NakesItem(
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
    _NakesItem(
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
    _NakesItem(
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
                      child: _NakesCard(item: item),
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
                        const _StepRow(
                          number: '1',
                          text: 'Bawa Buku KIA (Kesehatan Ibu dan Anak) dan KTP/BPJS.',
                        ),
                        const SizedBox(height: 8),
                        const _StepRow(
                          number: '2',
                          text: 'Tunjukkan hasil catatan pengukuran atau skrining dari aplikasi NURI kepada petugas di Poli KIA / Poli Gizi.',
                        ),
                        const SizedBox(height: 8),
                        const _StepRow(
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

class _NakesItem {
  const _NakesItem({
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

class _NakesCard extends StatelessWidget {
  const _NakesCard({required this.item});

  final _NakesItem item;

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
                      style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
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
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.muted),
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

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

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
