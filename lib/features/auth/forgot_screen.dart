import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_logo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';

/// Layar lupa kata sandi: memilih saluran pemulihan akun.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _channel = 0;

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/login'),
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
            const _ResetMark(),
            const SizedBox(height: 22),
            const PillLabel(text: 'PEMULIHAN AKUN • LANGKAH 1 DARI 2'),
            const SizedBox(height: 16),
            const Text(
              'Lupa Kata Sandi?',
              textAlign: TextAlign.center,
              style: AppText.h1,
            ),
            const SizedBox(height: 10),
            const Text(
              'Jangan khawatir, Bunda dan Ayah. Masukkan alamat email atau nomor '
              'WhatsApp yang terdaftar untuk menerima tautan pemulihan kata '
              'sandi yang aman.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'PILIHAN SALURAN PENGIRIMAN',
                    style: AppText.label,
                  ),
                ),
                Text(
                  'Tersinkronisasi',
                  style: AppText.caption.copyWith(color: AppColors.brandText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ChannelCard(
                    title: 'Via Email',
                    icon: Icons.mail_outline_rounded,
                    chipText: 'Rekomendasi',
                    chipColor: AppColors.pastelPink,
                    subtitle: 'Tautan kilat 1–klik',
                    selected: _channel == 0,
                    onTap: () => setState(() => _channel = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChannelCard(
                    title: 'Via WhatsApp',
                    icon: Icons.chat_bubble_outline_rounded,
                    chipText: '+62 Resmi',
                    chipColor: AppColors.surfaceSoft,
                    subtitle: 'Pesan terverifikasi',
                    selected: _channel == 1,
                    onTap: () => setState(() => _channel = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email atau Nomor WhatsApp / Ponsel *',
                    style: AppText.bodySm.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: AppText.body.copyWith(color: AppColors.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'contoh: bunda@email.com atau 08...',
                      hintStyle:
                          AppText.bodySm.copyWith(color: AppColors.inkFaint),
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        size: 20,
                        color: AppColors.inkFaint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLg),
                        borderSide: const BorderSide(
                          color: AppColors.brand,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const NoteRow(
                    icon: Icons.auto_awesome_rounded,
                    text: 'Mendeteksi otomatis metode pengiriman terbaik '
                        '(Email atau WhatsApp resmi NURI).',
                  ),
                  const SizedBox(height: 8),
                  const NoteRow(
                    icon: Icons.shield_outlined,
                    text: 'Pastikan kontak aktif untuk menerima tautan 6 digit '
                        'keamanan dari bot resmi NURI Health Pediatri.',
                  ),
                  const SizedBox(height: 18),
                  NuriPrimaryButton(
                    label: 'Kirim Tautan Pemulihan',
                    trailingArrow: true,
                    onPressed: () => context.go('/forgot-sent'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            NoteBox(
              icon: Icons.shield_outlined,
              background: AppColors.surfaceSoft,
              child: Text.rich(
                TextSpan(
                  style: AppText.bodySm,
                  children: [
                    TextSpan(
                      text: 'Perlindungan Data Keluarga',
                      style: AppText.bodyStrong,
                    ),
                    const TextSpan(
                      text: '\nTautan pemulihan berlaku selama 15 menit dan '
                          'hanya dapat digunakan satu kali demi melindungi '
                          'kerahasiaan riwayat nutrisi serta data pertumbuhan '
                          'si kecil.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                '← Kembali ke Masuk Akun',
                style: AppText.bodySm.copyWith(
                  color: AppColors.brandText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ingat kata sandi Anda? Masuk ke NURI',
              style: AppText.bodySm,
            ),
            const SizedBox(height: 16),
            const NoteRow(
              icon: Icons.support_agent_rounded,
              text: 'Butuh bantuan staf Posyandu? Hubungi Pusat Bantuan.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Lencana pemulihan akun: mark NURI dengan badge putar ulang.
class _ResetMark extends StatelessWidget {
  const _ResetMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
          ),
          child: const NuriMark(size: 36),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu pilihan saluran pemulihan (Email / WhatsApp).
class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.title,
    required this.icon,
    required this.chipText,
    required this.chipColor,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String chipText;
  final Color chipColor;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.canvasGreen : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.line,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(
                icon: icon,
                size: 44,
                color: selected ? AppColors.brand : AppColors.pastelGreenSoft,
                iconColor: selected ? Colors.white : AppColors.brand,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  chipText,
                  style: AppText.caption.copyWith(
                    color: AppColors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(title, style: AppText.title),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.caption),
            ],
          ),
        ),
      ),
    );
  }
}
