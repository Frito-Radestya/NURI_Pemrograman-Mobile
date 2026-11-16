import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'auth_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, this.initialRole});

  final UserRole? initialRole;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late UserRole _role;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole ?? UserRole.mother;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await ref
        .read(appControllerProvider.notifier)
        .loginWithGoogle(role: _role);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Konfirmasi password belum sama.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await ref
        .read(appControllerProvider.notifier)
        .register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          role: _role,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CurvedHeader(
              borderRadius: 40,
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.paddingOf(context).top + 16,
                20,
                52,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (Navigator.of(context).canPop())
                    Align(
                      alignment: Alignment.centerLeft,
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
                    )
                  else
                    const SizedBox(height: 8),
                  const SizedBox(height: 10),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/nuri_logo_mark.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.spa_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'NURI',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 2.5,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: '.',
                          style: TextStyle(color: AppColors.secondaryFixed),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _role == UserRole.mother
                        ? 'Daftar sebagai Ibu & Keluarga'
                        : 'Daftar sebagai Kader Posyandu',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NuriTextField(
                        label: 'Nama lengkap',
                        controller: _name,
                        hint: 'Contoh: Siti Rahma',
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 14),
                      NuriTextField(
                        label: 'Email',
                        controller: _email,
                        hint: _role == UserRole.mother
                            ? 'ibu_rina@gmail.com'
                            : 'kader_nur@gmail.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 14),
                      NuriTextField(
                        label: 'Password',
                        controller: _password,
                        hint: _role == UserRole.mother
                            ? 'ibu123456'
                            : 'kader123456',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 19,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      NuriTextField(
                        label: 'Ulangi password',
                        controller: _confirm,
                        hint: _role == UserRole.mother
                            ? 'ibu123456'
                            : 'kader123456',
                        prefixIcon: Icons.lock_reset_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.red,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      NuriButton(
                        label: 'Daftar & lanjutkan',
                        icon: Icons.arrow_forward_rounded,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'atau',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GoogleSignInButton(
                        loading: _loading,
                        onPressed: _submitGoogle,
                        label: 'Daftar dengan Google',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
