import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/ui.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Konsultasi Nakes',
              subtitle: 'Bidan dan perawat resmi wilayah Posyandu & Puskesmas',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF145C45), Color(0xFF0E4332)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF145C45).withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: AppColors.softMint,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tenaga Kesehatan Resmi',
                                style: TextStyle(
                                  color: AppColors.softMint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Dampingan Langsung Bidan & Perawat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Bila hasil skrining di NURI menunjukkan status "Perlu perhatian" atau "Perlu rujukan", Ibu dapat berkonsultasi langsung dengan bidan pembina.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Bidan & Perawat Wilayah Anda',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
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
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(10),
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Standar rujukan KIA Kemenkes RI',
                                      style: TextStyle(
                                        fontSize: 12,
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
                    const SizedBox(height: 14),
                    const NuriDisclaimer(),
                  ],
                ),
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
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
                                ? AppColors.mint
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: item.isReady
                                  ? AppColors.primary
                                  : AppColors.line,
                            ),
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
                              const SizedBox(width: 5),
                              Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: item.isReady
                                      ? AppColors.primary
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.schedule,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Layanan: ${item.specialty}',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    showNuriSnack(
                      context,
                      'Menghubungi ${item.name} via WhatsApp (${item.whatsapp})...',
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text(
                    'Konsultasi WA',
                    style: TextStyle(fontSize: 12.5),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  showNuriSnack(context, 'Menghubungi ${item.phone}...');
                },
                icon: const Icon(Icons.call_outlined, size: 16),
                label: const Text('Telepon', style: TextStyle(fontSize: 12.5)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.text,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
