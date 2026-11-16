import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'auth_signup_screen.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialRole, this.showBack = true});

  final UserRole? initialRole;
  final bool showBack;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late UserRole _role;
  final _email = TextEditingController();
  final _password = TextEditingController();
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
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _finish() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await ref
        .read(appControllerProvider.notifier)
        .login(_email.text, _password.text, role: _role);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    _finish();
  }

  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPasswordDialog(initialEmail: _email.text),
    );
    if (!mounted || email == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await ref
        .read(appControllerProvider.notifier)
        .resetPassword(email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    showNuriSnack(
      context,
      'Tautan reset password sudah dikirim. Periksa email dan folder spam.',
    );
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
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    final isMother = _role == UserRole.mother;

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
                  // Top Bar: Back button only
                  if (widget.showBack && Navigator.of(context).canPop())
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
                  // Round Pure NURI Logo Emblem without text
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
                  // Dedicated NURI wordmark
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
                    'Selamat Datang Kembali',
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
                    isMother
                        ? 'Portal Masuk Ibu & Keluarga'
                        : 'Portal Masuk Kader Posyandu',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onPrimaryContainer,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            // Form Card
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
                        label: 'Alamat Email atau NIK',
                        controller: _email,
                        hint: isMother
                            ? 'ibu_rina@gmail.com'
                            : 'kader_nur@gmail.com',
                        prefixIcon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                      ),
                      const SizedBox(height: 14),
                      NuriTextField(
                        label: 'Kata Sandi',
                        controller: _password,
                        hint: isMother ? 'ibu123456' : 'kader123456',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
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
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: AppColors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
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
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Ingat Saya',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _loading ? null : _forgotPassword,
                            child: const Text(
                              'Lupa Sandi?',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      NuriButton(
                        label: 'Masuk ke NURI',
                        icon: Icons.arrow_forward_rounded,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'atau masuk dengan',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GoogleSignInButton(
                        loading: _loading,
                        onPressed: _submitGoogle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(initialRole: _role),
                      ),
                    ),
                    child: const Text(
                      'Daftar sekarang',
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
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_email.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          NuriLogo(compact: true),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Reset Password',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masukkan email akun Firebase. Kami akan mengirim tautan untuk membuat password baru.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          NuriTextField(
            label: 'Email',
            controller: _email,
            hint: 'nama@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Kirim tautan')),
      ],
    );
  }
}
