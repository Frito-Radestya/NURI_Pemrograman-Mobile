import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/wave_header.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController(text: 'divaputri@gmail.com');
  final _passCtrl = TextEditingController(text: 'password123');

  UserRole _selectedRole = UserRole.ibuBalita;
  bool _obscure = true;
  bool _keepSignedIn = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await AuthService().login(
        identifier: _userCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email/kontak atau kata sandi tidak cocok. '
              'Gunakan akun demo atau akun terdaftar.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      AuthService().setKeepSignedIn(_keepSignedIn);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal Masuk: $e')));
    }
  }

  void _selectRole(UserRole role) {
    final demo = AuthService.demoUserForRole(role);
    setState(() {
      _selectedRole = role;
      _userCtrl.text = demo.emailOrPhone;
      _passCtrl.text = AuthService.demoPassword;
    });
  }

  void _quickDemo(UserRole role) async {
    setState(() => _isLoading = true);
    UserModel user;
    switch (role) {
      case UserRole.ibuBalita:
        user = UserModel.demoIbuBalita();
        break;
      case UserRole.ibuHamil:
        user = UserModel.demoIbuHamil();
        break;
      case UserRole.kaderPosyandu:
        user = UserModel.demoKader();
        break;
    }
    AuthService().setCurrentUser(user);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Masuk sebagai ${user.name} (${user.roleDisplayTitle})'),
        backgroundColor: user.role.color,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            WaveHeader(
              height: MediaQuery.of(context).size.height * 0.36,
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(size: 72, white: true),
                      const SizedBox(height: 10),
                      Text(
                        'NURI',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Nutrisi & Risiko Stunting Indonesia',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mode Switcher Tab (Sign In vs Sign Up)
                    Container(
                      height: 46,
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                'MASUK (SIGN IN)',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(
                                      initialRole: _selectedRole,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child: Text(
                                  'DAFTAR (SIGN UP)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Selamat Datang Kembali',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk ke akun NURI Anda untuk memantau gizi & kesehatan si kecil.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selector Peran Pengguna
                    Text(
                      'Peran Akun',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRoleChips(),
                    const SizedBox(height: 18),

                    // Input Email / Username
                    _inputField(
                      controller: _userCtrl,
                      icon: Icons.person_outline_rounded,
                      hint: 'Email atau Username',
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) {
                          return 'Email / Username tidak boleh kosong';
                        }
                        if (value.length < 3) {
                          return 'Minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Input Password
                    _inputField(
                      controller: _passCtrl,
                      icon: Icons.lock_outline_rounded,
                      hint: 'Kata Sandi',
                      obscureText: _obscure,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Kata sandi tidak boleh kosong';
                        }
                        if (v.length < 6) return 'Minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Keep signed in & Forgot Password
                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _keepSignedIn,
                            activeColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.6),
                            ),
                            onChanged: (v) =>
                                setState(() => _keepSignedIn = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ingat Saya',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Lupa Password?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Tombol Submit 
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'MASUK SEKARANG',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterScreen(initialRole: _selectedRole),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        label: Text(
                          'BUAT AKUN BARU (SIGN UP)',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Demo  Quick Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Masuk Cepat Mode Demo',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _demoChip(
                                  'Ibu Balita',
                                  UserRole.ibuBalita,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _demoChip(
                                  'Ibu Hamil',
                                  UserRole.ibuHamil,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _demoChip(
                                  'Kader',
                                  UserRole.kaderPosyandu,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider OPSI SOSIAL
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'atau masuk dengan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Social Buttons (Google & WhatsApp)
                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(
                            label: 'Masuk Demo',
                            iconWidget: const Icon(
                              Icons.bolt_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            onTap: () => _quickDemo(UserRole.ibuBalita),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _socialButton(
                            label: 'Lupa Password',
                            iconWidget: const Icon(
                              Icons.lock_reset_rounded,
                              color: Color(0xFF25D366),
                              size: 20,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Footer Link ke Sign Up
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterScreen(initialRole: _selectedRole),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                            children: [
                              const TextSpan(text: "Belum punya akun? "),
                              TextSpan(
                                text: 'Daftar Sekarang',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChips() {
    return Row(
      children: UserRole.values.map((role) {
        final isSelected = _selectedRole == role;
        return Expanded(
          child: GestureDetector(
            onTap: () => _selectRole(role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? role.bgLight : AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? role.color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    role.icon,
                    size: 20,
                    color: isSelected ? role.color : AppColors.textGrey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? role.color : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _demoChip(String label, UserRole role) {
    return ElevatedButton(
      onPressed: () => _quickDemo(role),
      style: ElevatedButton.styleFrom(
        backgroundColor: role.color.withValues(alpha: 0.12),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: role.color,
        ),
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.textGrey),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
