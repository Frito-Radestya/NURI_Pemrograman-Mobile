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
import '../../state/app_state.dart';

/// Layar masuk akun NURI.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Masuk: ke Supabase bila dikonfigurasi, jika tidak mode lokal.
  Future<void> _signInAsIbu() async {
    if (_loading) return;
    final NuriAppState state = NuriScope.read(context);
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    setState(() => _loading = true);
    try {
      if (state.cloudEnabled && email.isNotEmpty && password.isNotEmpty) {
        await state.authSignIn(email: email, password: password, role: 'ibu_balita');
      } else {
        state.signIn(name: 'Bunda', role: 'ibu_balita');
      }
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal masuk: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/role'),
        titleWidget: const NuriBrand(markSize: 30),
        actions: const [NuriAvatar()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const NuriMark(size: 44),
                const SizedBox(width: 12),
                const Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NuriWordmark(fontSize: 22, color: AppColors.ink),
                      Text(
                        'Nutrisi & Tumbuh Kembang',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const DotBadge(text: 'Pediatrik & Gizi'),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Selamat Datang Kembali', style: AppText.h1),
            const SizedBox(height: 10),
            const Text(
              'Masuk untuk melanjutkan pemantauan tumbuh kembang si kecil dan '
              'akses panduan gizi harian yang terarah.',
              style: AppText.body,
            ),
            const SizedBox(height: 22),
            _NuriField(
              label: 'Email atau Nomor WhatsApp / Ponsel',
              hint: 'contoh: bunda@email.com atau 0812...',
              icon: Icons.person_outline_rounded,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            _NuriField(
              label: 'Kata Sandi',
              hint: 'Minimal 8 karakter',
              icon: Icons.lock_outline_rounded,
              controller: _passwordController,
              obscure: _obscure,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.inkFaint,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                  activeColor: AppColors.brand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ingat Saya',
                  style: AppText.bodySm.copyWith(color: AppColors.ink),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go('/forgot'),
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: AppText.bodySm.copyWith(
                      color: AppColors.brandText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            NuriCard(
              color: AppColors.surfaceSoft,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.pastelGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.brand,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Login Cepat Biometrik', style: AppText.title),
                        SizedBox(height: 2),
                        Text(
                          'Gunakan Sidik Jari atau Face ID',
                          style: AppText.bodySm,
                        ),
                      ],
                    ),
                  ),
                  _MiniPill(label: 'Aktifkan', onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 22),
            NuriPrimaryButton(
              label: 'Masuk ke NURI',
              trailingArrow: true,
              loading: _loading,
              onPressed: _signInAsIbu,
            ),
            const SizedBox(height: 22),
            const LabeledDivider(label: 'ATAU MASUK DENGAN METODE AMAN'),
            const SizedBox(height: 18),
            NuriSecondaryButton(
              label: 'Masuk dengan Kode OTP WhatsApp',
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: _signInAsIbu,
            ),
            const SizedBox(height: 12),
            NuriSecondaryButton(
              label: 'Lanjutkan dengan Google',
              icon: Icons.g_mobiledata_rounded,
              onPressed: _signInAsIbu,
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Belum memiliki akun NURI? ',
                    style: AppText.bodySm,
                  ),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text(
                      'Daftar Sekarang',
                      style: AppText.bodySm.copyWith(
                        color: AppColors.brandText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const NoteRow(
              icon: Icons.lock_outline_rounded,
              text: 'Data antropometri dan rekap gizi keluarga terlindungi '
                  'secara terenkripsi.',
            ),
          ],
        ),
      ),
    );
  }
}

/// Bidang isian teks bergaya NURI dengan label di atas.
class _NuriField extends StatelessWidget {
  const _NuriField({
    required this.label,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.suffix,
    this.controller,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final Widget? suffix;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodySm.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppText.body.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: AppText.bodySm.copyWith(color: AppColors.inkFaint),
            prefixIcon:
                icon != null ? Icon(icon, size: 20, color: AppColors.inkFaint) : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              borderSide: const BorderSide(color: AppColors.brand, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pil kecil putih untuk aksi ringan di dalam kartu.
class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: AppText.bodySm.copyWith(
              color: AppColors.brandText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
