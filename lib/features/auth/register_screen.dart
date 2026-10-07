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

/// Layar pendaftaran akun NURI.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscure = true;
  bool _agree = true;
  bool _loading = false;

  final TextEditingController _nameController =
      TextEditingController(text: 'Siti Rahmawati');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Mendaftarkan akun: ke Supabase bila dikonfigurasi, jika tidak mode lokal.
  Future<void> _continueRegistration() async {
    final NuriAppState state = NuriScope.read(context);
    final String nama = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    setState(() => _loading = true);
    try {
      if (state.cloudEnabled && email.isNotEmpty && password.isNotEmpty) {
        await state.authSignUp(
          email: email,
          password: password,
          name: nama.isNotEmpty ? nama : email.split('@').first,
          role: 'ibu_balita',
        );
      } else {
        state.signIn(
          name: nama.isNotEmpty ? nama : 'Bunda',
          role: 'ibu_balita',
          email: email.isNotEmpty ? email : null,
        );
      }
      if (mounted) context.go('/child-data');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pendaftaran gagal: $e')),
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
        onBack: () => context.canPop() ? context.pop() : context.go('/login'),
        titleWidget: const NuriBrand(markSize: 30),
        actions: [
          const NuriAvatar(),
          const SizedBox(width: 8),
          NuriSoftButton(
            icon: Icons.close_rounded,
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SelectedRoleCard(),
            const SizedBox(height: 20),
            const PillLabel(text: 'LANGKAH 1 DARI 2 • AKUN PENGGUNA'),
            const SizedBox(height: 16),
            const Text('Buat Akun NURI', style: AppText.h1),
            const SizedBox(height: 10),
            const Text(
              'Daftar untuk mulai memantau kurva tumbuh kembang si kecil, '
              'asupan nutrisi seimbang, dan deteksi dini risiko stunting '
              'secara presisi.',
              style: AppText.body,
            ),
            const SizedBox(height: 22),
            _NuriField(
              label: 'Nama Lengkap *',
              hint: 'contoh: Siti Rahmawati',
              icon: Icons.person_outline_rounded,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            _NuriField(
              label: 'Nomor WhatsApp / Ponsel *',
              hint: '81234567890',
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              prefix: const _PhonePrefix(),
              labelTrailing: Text(
                '⚡ Verifikasi Cepat',
                style: AppText.caption.copyWith(
                  color: AppColors.brandText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const NoteRow(
              icon: Icons.schedule_rounded,
              text: 'Digunakan untuk pengiriman kode verifikasi cepat & '
                  'pengingat jadwal posyandu si kecil.',
            ),
            const SizedBox(height: 16),
            _NuriField(
              label: 'Alamat Email',
              hint: 'nama@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              labelTrailing: Text(
                'Opsional / Direkomendasikan',
                style: AppText.caption,
              ),
            ),
            const SizedBox(height: 16),
            _NuriField(
              label: 'Kata Sandi *',
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: _StrengthBar(color: AppColors.brand)),
                const SizedBox(width: 6),
                const Expanded(child: _StrengthBar(color: AppColors.brand)),
                const SizedBox(width: 6),
                const Expanded(child: _StrengthBar(color: AppColors.brand)),
                const SizedBox(width: 12),
                Text(
                  'Cukup',
                  style: AppText.caption.copyWith(
                    color: AppColors.brandText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            NuriCard(
              color: AppColors.surfaceSoft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agree,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                    activeColor: AppColors.brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: AppText.bodySm,
                        children: [
                          const TextSpan(text: 'Saya menyetujui '),
                          TextSpan(
                            text: 'Ketentuan Layanan',
                            style: AppText.bodySm.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' & '),
                          TextSpan(
                            text: 'Kebijakan Privasi NURI',
                            style: AppText.bodySm.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text: ' terkait perlindungan data kesehatan anak.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const NoteRow(
              icon: Icons.shield_outlined,
              text: 'Data rekam medis & pertumbuhan dienkripsi sesuai standar '
                  'privasi kesehatan.',
            ),
            const SizedBox(height: 22),
            NuriPrimaryButton(
              label: 'Lanjutkan Pendaftaran',
              trailingArrow: true,
              loading: _loading,
              onPressed: _continueRegistration,
            ),
            const SizedBox(height: 22),
            const LabeledDivider(label: 'ATAU DAFTAR DENGAN'),
            const SizedBox(height: 18),
            NuriSecondaryButton(
              label: 'Daftar Cepat dengan Google',
              icon: Icons.g_mobiledata_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Sudah memiliki akun NURI? ',
                    style: AppText.bodySm,
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Masuk Akun',
                      style: AppText.bodySm.copyWith(
                        color: AppColors.brandText,
                        fontWeight: FontWeight.w700,
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

/// Kartu peran yang sedang dipilih pada langkah pendaftaran.
class _SelectedRoleCard extends StatelessWidget {
  const _SelectedRoleCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.pastelGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: AppColors.brand,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PillLabel(text: 'Peran Terpilih', leadingDot: false),
                SizedBox(height: 8),
                Text('Ibu Balita (0–5 Tahun)', style: AppText.h3),
                SizedBox(height: 3),
                Text(
                  'Panduan nutrisi & kurva WHO disesuaikan personal.',
                  style: AppText.bodySm,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Tag(text: 'Ubah'),
        ],
      ),
    );
  }
}

/// Bar tipis indikator kekuatan kata sandi.
class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

/// Prefiks "+62 |" untuk kolom nomor telepon.
class _PhonePrefix extends StatelessWidget {
  const _PhonePrefix();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+62',
            style: AppText.bodyStrong.copyWith(color: AppColors.ink),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 22, color: AppColors.line),
        ],
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
    this.prefix,
    this.labelTrailing,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.controller,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final Widget? prefix;
  final Widget? labelTrailing;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.bodySm.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ?labelTrailing,
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: AppText.body.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: AppText.bodySm.copyWith(color: AppColors.inkFaint),
            prefixIcon: prefix ??
                (icon != null
                    ? Icon(icon, size: 20, color: AppColors.inkFaint)
                    : null),
            prefixIconConstraints: prefix != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
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
