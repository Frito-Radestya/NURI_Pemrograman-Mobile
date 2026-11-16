import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
              child: Row(
                children: [
                  const NuriLogo(compact: true),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        ref.read(appControllerProvider.notifier).logout(),
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privasi & persetujuan',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sebelum mulai, pastikan Ibu nyaman dengan cara data digunakan.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        children: [
                          NuriInfoRow(
                            icon: Icons.folder_open_rounded,
                            title: 'Data yang dicatat',
                            subtitle: 'Profil, pengukuran tumbuh kembang, catatan makan, dan data kehamilan yang Ibu isi sendiri.',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          NuriInfoRow(
                            icon: Icons.visibility_outlined,
                            title: 'Siapa yang bisa melihat',
                            subtitle: 'Ibu memegang kendali penuh. Kader hanya dapat melihat data yang Ibu izinkan.',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          NuriInfoRow(
                            icon: Icons.tune_rounded,
                            title: 'Kendali penuh di tangan Ibu',
                            subtitle: 'Cabut akses kader, ubah data, atau hapus data demo dari perangkat kapan saja.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _accepted = !_accepted);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _accepted
                              ? AppColors.softMint
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _accepted
                                ? AppColors.deepForest
                                : AppColors.line,
                            width: _accepted ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: _accepted
                                    ? AppColors.deepForest
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _accepted
                                      ? AppColors.deepForest
                                      : AppColors.muted,
                                  width: 1.5,
                                ),
                              ),
                              child: _accepted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Saya memahami dan menyetujui penggunaan data untuk skrining gizi serta tumbuh kembang.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton(
                        onPressed: () => _showPolicy(context),
                        child: const Text('Baca kebijakan lengkap'),
                      ),
                    ),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: NuriButton(
                label: 'Setujui & lanjutkan',
                icon: Icons.arrow_forward_rounded,
                onPressed: _accepted
                    ? () => ref
                          .read(appControllerProvider.notifier)
                          .acceptConsent()
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPolicy(BuildContext context) {
    showNuriSheet(context: context, builder: (context) => const _PolicySheet());
  }
}

class _PolicySheet extends StatelessWidget {
  const _PolicySheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kebijakan Privasi NURI',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Versi 2026-11 • Berlaku untuk demo lokal',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          const Text(
            'NURI membantu Ibu dan kader posyandu memantau gizi serta tumbuh kembang. Data yang Ibu masukkan disimpan di perangkat pada versi demo ini dan tidak dikirim ke server mana pun.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          const _PolicySection(
            title: '1. Data yang diproses',
            body: 'Nama, tanggal lahir, jenis kelamin, pengukuran antropometri, catatan makan, data kehamilan, dan kontak yang Ibu berikan. NURI tidak meminta NIK, alamat lengkap, atau data medis sensitif lainnya pada demo ini.',
          ),
          const _PolicySection(
            title: '2. Dasar penggunaan',
            body: 'Data digunakan untuk menampilkan skrining pertumbuhan, estimasi asupan gizi, pengingat, dan tindak lanjut. Hasil skrining bukan diagnosis dan tidak menggantikan pemeriksaan tenaga kesehatan.',
          ),
          const _PolicySection(
            title: '3. Berbagi dengan kader',
            body: 'Ibu dapat memberikan akses kepada kader untuk melihat atau mencatat pengukuran. Akses memiliki cakupan dan masa berlaku, serta dapat dicabut dari menu Privasi & akses.',
          ),
          const _PolicySection(
            title: '4. Penyimpanan & keamanan',
            body: 'Pada versi demo, data disimpan di penyimpanan lokal perangkat. Versi produksi akan memakai Firebase dengan aturan keamanan per pengguna, enkripsi saat transit, dan audit akses.',
          ),
          const _PolicySection(
            title: '5. Hak Ibu',
            body: 'Ibu berhak mengakses, memperbaiki, mengekspor, dan menghapus data. Gunakan menu Data demo untuk mengatur ulang data demo di perangkat ini.',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
