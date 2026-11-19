import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../profile/profile_sheets.dart';
import 'consultation_widgets.dart';
import 'nakes_chat_screen.dart';

class ConsultationScreen extends ConsumerWidget {
  const ConsultationScreen({super.key});

  static const _nakesList = [
    NakesItem(
      id: 'nakes_siti',
      name: 'Bidan Siti Aminah, S.Tr.Keb',
      role: 'Bidan Desa & Pembina Posyandu',
      facility: 'Pustu Sukamaju • Wilayah Posyandu Melati II',
      specialty: 'Pemeriksaan Kehamilan (ANC), Rujukan USG, Stunting Balita',
      status: 'Siap Konsultasi',
      isReady: true,
      schedule: 'Senin–Jumat • 08:00–16:00',
    ),
    NakesItem(
      id: 'nakes_ratna',
      name: 'Bidan Ratna Dewi, A.Md.Keb',
      role: 'Bidan Praktik Mandiri (BPM)',
      facility: 'Klinik Bersalin Pratama Sukamaju',
      specialty: 'Pemantauan Denyut Janin, Konseling ASI & Imunisasi',
      status: 'Siap Konsultasi',
      isReady: true,
      schedule: 'Praktik Sore • 16:00–20:30',
    ),
    NakesItem(
      id: 'nakes_hendra',
      name: 'dr. Hendra Pratama, Sp.A',
      role: 'Dokter Puskesmas & Konsultan Gizi',
      facility: 'Puskesmas Sukamaju Induk',
      specialty: 'Intervensi Gizi Kurang, PKMK Balita, Skrining KEK Ibu Hamil',
      status: 'Jadwal Piket',
      isReady: true,
      schedule: 'Senin–Sabtu • 08:00–14:00',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final isCadre = state.isCadre;
    final connected = state.isPosyanduConnected;
    final assignedIds = state.assignedNakesIds;
    final visibleNakes = isCadre
        ? _nakesList
        : _nakesList.where((n) => assignedIds.contains(n.id)).toList();
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
                  Text(
                    isCadre
                        ? 'Atur Bidan & Dokter Pendamping'
                        : 'Bidan & Dokter Wilayah Anda',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (isCadre) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih bidan atau dokter yang bersedia, sesuai, dan mampu mendampingi Ibu di wilayah Posyandu Anda. Ketuk Kirim Pesan untuk membalas pesan Ibu.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (!isCadre && !connected)
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.link_off_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Belum Tersambung ke Posyandu',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sambungkan akun Ibu dengan Posyandu terlebih dahulu agar Kader dapat mengatur dan menghubungkan bidan atau dokter pendamping yang sesuai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          NuriButton(
                            label: 'Sambungkan Kode Posyandu',
                            icon: Icons.qr_code_rounded,
                            onPressed: () async {
                              final code = await showNuriSheet<String>(
                                context: context,
                                builder: (_) =>
                                    const ConnectPosyanduCodeSheet(),
                              );
                              if (!context.mounted ||
                                  code == null ||
                                  code.isEmpty) {
                                return;
                              }
                              final err = ref
                                  .read(appControllerProvider.notifier)
                                  .connectPosyanduCode(code);
                              if (!context.mounted) return;
                              if (err != null) {
                                showNuriSnack(context, err, error: true);
                              } else {
                                showNuriSnack(
                                  context,
                                  'Berhasil tersambung ke Posyandu!',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  else if (!isCadre && visibleNakes.isEmpty)
                    const AppCard(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            size: 34,
                            color: AppColors.amber,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Menunggu Penugasan Kader',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pihak Kader Posyandu sedang mengatur bidan atau dokter yang bersedia, sesuai, dan mampu mendampingi konsultasi Ibu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...visibleNakes.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NakesCard(
                          item: item,
                          isAssigned: assignedIds.contains(item.id),
                          onToggleAssign: isCadre
                              ? () {
                                  ref
                                      .read(appControllerProvider.notifier)
                                      .toggleNakesAssignment(item.id);
                                  final nowAssigned = !assignedIds.contains(
                                    item.id,
                                  );
                                  showNuriSnack(
                                    context,
                                    nowAssigned
                                        ? '${item.name} ditugaskan untuk konsultasi Ibu.'
                                        : 'Penugasan ${item.name} dinonaktifkan.',
                                  );
                                }
                              : null,
                          onChat: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NakesChatScreen(item: item),
                            ),
                          ),
                        ),
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
