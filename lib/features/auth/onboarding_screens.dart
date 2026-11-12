import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) => const LoginScreen(showBack: false);
}

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

  void _selectRole(UserRole role) {
    if (_role == role) return;
    setState(() {
      _role = role;
      _error = null;
    });
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
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.showBack && Navigator.of(context).canPop())
                    RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    )
                  else
                    const SizedBox(width: 40),
                  const Spacer(),
                  const NuriLogo(compact: true),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Selamat datang kembali',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                'Masuk untuk melanjutkan pantauan Ibu dan Si Kecil.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              NuriSegmentedControl<UserRole>(
                values: const [UserRole.mother, UserRole.cadre],
                selected: _role,
                labelFor: (value) => value == UserRole.mother
                    ? 'Ibu / Keluarga'
                    : 'Kader Posyandu',
                onChanged: _selectRole,
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
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
                    const SizedBox(height: 16),
                    NuriButton(
                      label: 'Masuk',
                      icon: Icons.login_rounded,
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: _loading ? null : _forgotPassword,
                        child: const Text(
                          'Lupa password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
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
                    _GoogleSignInButton(
                      loading: _loading,
                      onPressed: _submitGoogle,
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
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
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.loading,
    required this.onPressed,
    this.label = 'Masuk dengan Google',
  });

  final bool loading;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GoogleLogoIcon(),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
    );
  }
}

class _GoogleLogoIcon extends StatelessWidget {
  const _GoogleLogoIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(18, 18), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w / 2;

    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    // 4 quadrants arcs
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.785,
      1.57,
      true,
      blue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.785,
      1.57,
      true,
      green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.355,
      1.57,
      true,
      yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.925,
      1.57,
      true,
      red,
    );

    // Inner cutout
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.58, white);

    // Center bar
    final barRect = Rect.fromLTRB(
      cx - r * 0.1,
      cy - r * 0.22,
      w * 0.95,
      cy + r * 0.22,
    );
    canvas.drawRect(barRect, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      title: const Text('Reset password'),
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
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                title: 'Buat akun NURI',
                subtitle: 'Gratis, tenang, dan bisa dipakai offline.',
                padding: EdgeInsets.fromLTRB(0, 6, 0, 14),
              ),
              AppCard(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 16),
                    const NuriFormLabel(text: 'Saya mendaftar sebagai'),
                    NuriSegmentedControl<UserRole>(
                      values: const [UserRole.mother, UserRole.cadre],
                      selected: _role,
                      labelFor: (value) => value == UserRole.mother
                          ? 'Ibu / Keluarga'
                          : 'Kader Posyandu',
                      onChanged: (value) => setState(() => _role = value),
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
                    _GoogleSignInButton(
                      loading: _loading,
                      onPressed: _submitGoogle,
                      label: 'Daftar dengan Google',
                    ),
                  ],
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
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
    );
  }
}

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    if (state.currentUser == null) {
      return const AuthScreen();
    }
    if (!state.consentAccepted) {
      return const ConsentScreen();
    }
    return RoleSetupScreen(role: role);
  }
}

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
                          color: _accepted ? AppColors.mint : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _accepted
                                ? AppColors.primary
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
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _accepted
                                      ? AppColors.primary
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

class RoleSetupScreen extends ConsumerStatefulWidget {
  const RoleSetupScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RoleSetupScreen> createState() => _RoleSetupScreenState();
}

class _RoleSetupScreenState extends ConsumerState<RoleSetupScreen> {
  bool _pregnant = true;
  bool _hasChild = false;
  DateTime? _hpht = DateTime.now().subtract(const Duration(days: 70));
  final _childName = TextEditingController();
  DateTime? _childDob;
  Sex _childSex = Sex.male;
  final _birthWeight = TextEditingController();
  final _birthLength = TextEditingController();
  late final _posyanduName = TextEditingController(
    text: ref.read(appControllerProvider).posyanduName,
  );
  late final _posyanduArea = TextEditingController(
    text: ref.read(appControllerProvider).posyanduArea,
  );
  bool _saving = false;

  @override
  void dispose() {
    _childName.dispose();
    _birthWeight.dispose();
    _birthLength.dispose();
    _posyanduName.dispose();
    _posyanduArea.dispose();
    super.dispose();
  }

  Future<void> _finishMother() async {
    FocusScope.of(context).unfocus();
    if (!_pregnant && !_hasChild) {
      showNuriSnack(
        context,
        'Pilih minimal satu: kehamilan atau data anak.',
        error: true,
      );
      return;
    }
    if (_pregnant && _hpht == null) {
      showNuriSnack(context, 'Tanggal HPHT belum dipilih.', error: true);
      return;
    }
    if (_hasChild && _childName.text.trim().length < 2) {
      showNuriSnack(
        context,
        'Nama panggilan anak minimal 2 karakter.',
        error: true,
      );
      return;
    }
    if (_hasChild && _childDob == null) {
      showNuriSnack(context, 'Tanggal lahir anak belum dipilih.', error: true);
      return;
    }
    setState(() => _saving = true);
    final controller = ref.read(appControllerProvider.notifier);
    if (_pregnant && ref.read(appControllerProvider).activePregnancy == null) {
      controller.addPregnancy(hpht: _hpht!);
    }
    if (_hasChild) {
      final error = controller.addChild(
        nickname: _childName.text,
        dob: _childDob!,
        sex: _childSex,
        birthWeightKg: double.tryParse(_birthWeight.text.replaceAll(',', '.')),
        birthLengthCm: double.tryParse(_birthLength.text.replaceAll(',', '.')),
      );
      if (error != null) {
        if (!mounted) return;
        setState(() => _saving = false);
        showNuriSnack(context, error, error: true);
        return;
      }
    }
    controller.completeOnboarding();
  }

  void _finishCadre() {
    if (_posyanduName.text.trim().length < 3) {
      showNuriSnack(context, 'Nama posyandu minimal 3 karakter.', error: true);
      return;
    }
    final controller = ref.read(appControllerProvider.notifier);
    controller.setPosyandu(name: _posyanduName.text, area: _posyanduArea.text);
    controller.completeOnboarding();
  }

  void _skip() {
    ref.read(appControllerProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isCadre = widget.role == UserRole.cadre;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NuriStepHeader(
                      step: 2,
                      total: 2,
                      title: isCadre
                          ? 'Kenali Posyandu Anda'
                          : 'Kenali Ibu & Si Kecil',
                      subtitle: isCadre
                          ? 'Data ini membantu NURI menampilkan sesi dan sasaran yang tepat.'
                          : 'Pilih apa yang ingin Ibu pantau. Bisa diubah nanti.',
                      onClose: () =>
                          ref.read(appControllerProvider.notifier).logout(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isCadre ? _buildCadre() : _buildMother(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  NuriButton(
                    label: isCadre ? 'Mulai kelola sesi' : 'Simpan & mulai',
                    icon: Icons.check_rounded,
                    loading: _saving,
                    onPressed: isCadre ? _finishCadre : _finishMother,
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Lewati untuk sekarang'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMother() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SetupToggleCard(
          selected: _pregnant,
          icon: Icons.pregnant_woman_rounded,
          title: 'Saya sedang hamil',
          subtitle: 'Pantau usia kehamilan, TTD, ANC, dan pemeriksaan',
          onTap: () => setState(() => _pregnant = !_pregnant),
        ),
        if (_pregnant) ...[
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                NuriDateField(
                  label: 'Hari pertama haid terakhir (HPHT)',
                  value: _hpht,
                  firstDate: DateTime.now().subtract(const Duration(days: 280)),
                  lastDate: DateTime.now(),
                  helper: _hpht == null
                      ? 'HPHT dipakai untuk menghitung usia kehamilan dan perkiraan lahir.'
                      : 'Perkiraan lahir: ${formatDateId(PregnancyCalculator.hplFromHpht(_hpht!))}',
                  onChanged: (value) => setState(() => _hpht = value),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(
                      () => _hpht = DateTime.now().subtract(
                        const Duration(days: 84),
                      ),
                    ),
                    icon: const Icon(Icons.help_outline_rounded, size: 16),
                    label: const Text(
                      'Tidak tahu HPHT? Pakai perkiraan 12 minggu',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        _SetupToggleCard(
          selected: _hasChild,
          icon: Icons.child_care_rounded,
          title: 'Saya memiliki anak balita',
          subtitle: 'Catat pengukuran dan gizi harian anak 0–59 bulan',
          onTap: () => setState(() => _hasChild = !_hasChild),
        ),
        if (_hasChild) ...[
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                NuriTextField(
                  label: 'Nama panggilan anak',
                  controller: _childName,
                  hint: 'Contoh: Rafi',
                  prefixIcon: Icons.face_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                NuriDateField(
                  label: 'Tanggal lahir',
                  value: _childDob,
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 1856),
                  ),
                  lastDate: DateTime.now(),
                  onChanged: (value) => setState(() => _childDob = value),
                ),
                const SizedBox(height: 12),
                const NuriFormLabel(text: 'Jenis kelamin'),
                NuriSegmentedControl<Sex>(
                  values: const [Sex.male, Sex.female],
                  selected: _childSex,
                  labelFor: (value) => value.label,
                  onChanged: (value) => setState(() => _childSex = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NuriTextField(
                        label: 'BB lahir (kg, opsional)',
                        controller: _birthWeight,
                        hint: '3,1',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NuriTextField(
                        label: 'PB lahir (cm, opsional)',
                        controller: _birthLength,
                        hint: '49',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        const NuriDisclaimer(),
      ],
    );
  }

  Widget _buildCadre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              NuriTextField(
                label: 'Nama posyandu',
                controller: _posyanduName,
                hint: 'Posyandu Melati II',
                prefixIcon: Icons.home_work_outlined,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              NuriTextField(
                label: 'Wilayah / kelurahan',
                controller: _posyanduArea,
                hint: 'Kelurahan Sukamaju',
                prefixIcon: Icons.location_on_outlined,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          title: 'Mode offline siap',
          body: 'Kader dapat mencatat pengukuran tanpa sinyal dan menyinkronkan saat jaringan tersedia.',
          icon: Icons.cloud_off_rounded,
        ),
        const NuriDisclaimer(),
      ],
    );
  }
}

class _SetupToggleCard extends StatelessWidget {
  const _SetupToggleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.mint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 21,
                color: selected ? Colors.white : AppColors.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.line,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
