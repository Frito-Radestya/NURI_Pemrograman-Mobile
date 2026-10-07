import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_logo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';

/// Konfirmasi bahwa tautan pemulihan kata sandi telah dikirim.
class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/forgot'),
        titleWidget: const NuriBrand(markSize: 30),
        actions: [
          NuriSoftButton(icon: Icons.help_outline_rounded, onPressed: () {}),
          const SizedBox(width: 8),
          const NuriAvatar(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const PillLabel(text: 'TAUTAN TERKIRIM • PEMULIHAN AKUN'),
            const SizedBox(height: 24),
            const _SentIllustration(),
            const SizedBox(height: 24),
            const Text(
              'Cek Kotak Masuk Anda',
              textAlign: TextAlign.center,
              style: AppText.h1,
            ),
            const SizedBox(height: 10),
            const Text(
              'Kami telah mengirimkan instruksi dan tautan pemulihan kata sandi '
              'ke:',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const SizedBox(height: 20),
            const NuriCard(
              child: Row(
                children: [
                  _AccountBadge(),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AKUN TERDAFTAR', style: AppText.label),
                        SizedBox(height: 3),
                        Text(
                          'bunda.siti@email.com',
                          style: AppText.h3,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.statusNormal,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            NoteBox(
              icon: Icons.lock_outline_rounded,
              background: AppColors.surfaceSoft,
              child: Text.rich(
                TextSpan(
                  style: AppText.bodySm,
                  children: [
                    const TextSpan(
                      text: 'Klik tautan di dalam email untuk membuat kata '
                          'sandi baru. Tautan ini ',
                    ),
                    TextSpan(
                      text: 'hanya berlaku 15 menit',
                      style: AppText.bodyStrong,
                    ),
                    const TextSpan(
                      text: ' demi menjaga kerahasiaan catatan kesehatan dan '
                          'tumbuh kembang ananda.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            NuriPrimaryButton(
              label: 'Buka Aplikasi Email',
              icon: Icons.mail_outline_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            NuriSecondaryButton(
              label: 'Kembali ke Masuk Akun',
              icon: Icons.arrow_back_rounded,
              filled: true,
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: 22),
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      _QuestionBadge(),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Belum menerima email?',
                          style: AppText.h3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pastikan untuk memeriksa folder Spam atau tab Promosi di '
                    'aplikasi email Anda.',
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 16),
                  NuriSecondaryButton(
                    label: 'Kirim Ulang Tautan (00:42)',
                    icon: Icons.refresh_rounded,
                    filled: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  NuriSecondaryButton(
                    label: 'Kirim Kode Pemulihan via WhatsApp',
                    icon: Icons.chat_bubble_outline_rounded,
                    filled: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Masih terkendala masuk? ',
                    style: AppText.bodySm,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Hubungi Bantuan NURI',
                      style: AppText.bodySm.copyWith(
                        color: AppColors.brandText,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
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

/// Ilustrasi amplop terkirim dengan aksen dekoratif.
class _SentIllustration extends StatelessWidget {
  const _SentIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: AppColors.pastelGreenSoft,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              size: 48,
              color: AppColors.brand,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 22,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.brand,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 26,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.pastelPink,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 42,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.pastelGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lingkaran hijau dengan simbol @ untuk kartu akun.
class _AccountBadge extends StatelessWidget {
  const _AccountBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.pastelGreen,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.alternate_email_rounded,
        color: AppColors.brand,
        size: 22,
      ),
    );
  }
}

/// Lingkaran oranye dengan tanda tanya.
class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.pastelPeach,
        shape: BoxShape.circle,
      ),
      child: Text(
        '?',
        style: AppText.h3.copyWith(color: const Color(0xFFD9743A)),
      ),
    );
  }
}
