import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/wave_header.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole initialRole;

  const RegisterScreen({super.key, this.initialRole = UserRole.ibuBalita});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserRole _selectedRole;

  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Role specific controllers
  final _childNameCtrl = TextEditingController();
  final _childAgeCtrl = TextEditingController();
  final _pregnancyWeekCtrl = TextEditingController();
  final _posyanduNameCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _childNameCtrl.dispose();
    _childAgeCtrl.dispose();
    _pregnancyWeekCtrl.dispose();
    _posyanduNameCtrl.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0;
    if (password.length >= 6) score += 0.3;
    if (password.length >= 8) score += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
    return score.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double score) {
    if (score < 0.4) return Colors.redAccent;
    if (score < 0.75) return Colors.orangeAccent;
    return Colors.green;
  }

  String _getStrengthLabel(double score) {
    if (score == 0) return '';
    if (score < 0.4) return 'Lemah';
    if (score < 0.75) return 'Sedang';
    return 'Kuat & Aman';
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat & Kebijakan Privasi.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().sendOtp(_contactCtrl.text.trim());
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            contact: _contactCtrl.text.trim(),
            isFromRegister: true,
            userName: _nameCtrl.text.trim(),
            role: _selectedRole,
            childName: _childNameCtrl.text.trim().isNotEmpty
                ? _childNameCtrl.text.trim()
                : null,
            childAgeMonths: int.tryParse(_childAgeCtrl.text.trim()),
            pregnancyWeeks: int.tryParse(_pregnancyWeekCtrl.text.trim()),
            posyanduName: _posyanduNameCtrl.text.trim().isNotEmpty
                ? _posyanduNameCtrl.text.trim()
                : null,
            password: _passCtrl.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mendaftar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            WaveHeader(
              height: MediaQuery.of(context).size.height * 0.30,
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 12,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppLogo(size: 58, white: true),
                          const SizedBox(height: 8),
                          Text(
                            'DAFTAR AKUN NURI',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Solusi Pencegahan Stunting & Nutrisi Keluarga',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Peran Anda',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih profil untuk penyesuaian fitur & rekomendasi gizi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildRoleSelector(),
                    const SizedBox(height: 24),
                    Text(
                      'Informasi Pengguna',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _inputField(
                      controller: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                      hint: 'Nama Lengkap',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _inputField(
                      controller: _contactCtrl,
                      icon: Icons.email_outlined,
                      hint: 'Email atau No. WhatsApp (e.g. 0812...)',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) {
                          return 'Email/No. WhatsApp wajib diisi';
                        }
                        final emailPattern = RegExp(
                          r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                        );
                        final phonePattern = RegExp(r'^0\d{8,14}$');
                        if (!emailPattern.hasMatch(value) &&
                            !phonePattern.hasMatch(value)) {
                          return 'Gunakan email valid atau nomor 08xxxxxxxxxx';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildRoleSpecificFields(),
                    const SizedBox(height: 14),
                    _inputField(
                      controller: _passCtrl,
                      icon: Icons.lock_outline_rounded,
                      hint: 'Kata Sandi',
                      obscureText: _obscurePass,
                      onChanged: (v) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                      validator: (v) {
                        final value = v ?? '';
                        if (value.length < 8) {
                          return 'Kata sandi minimal 8 karakter';
                        }
                        if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
                            !RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Gunakan kombinasi huruf dan angka';
                        }
                        return null;
                      },
                    ),
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 14),
                    _inputField(
                      controller: _confirmPassCtrl,
                      icon: Icons.lock_clock_outlined,
                      hint: 'Konfirmasi Kata Sandi',
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v != _passCtrl.text) {
                          return 'Kata sandi tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeTerms,
                            activeColor: AppColors.primary,
                            onChanged: (v) =>
                                setState(() => _agreeTerms = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'Saya menyetujui '),
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const TextSpan(text: ' dan '),
                                TextSpan(
                                  text: 'Kebijakan Privasi Data (UU PDP)',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
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
                          onPressed: _isLoading ? null : _handleRegister,
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
                                  'DAFTAR SEKARANG',
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
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                            children: [
                              const TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(
                                text: 'Masuk di sini',
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

  Widget _buildRoleSelector() {
    return Column(
      children: UserRole.values.map((role) {
        final isSelected = _selectedRole == role;
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? role.bgLight : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? role.color : Colors.grey.shade200,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? role.color : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(role.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? role.color : AppColors.textDark,
                        ),
                      ),
                      Text(
                        role.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: role.color, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoleSpecificFields() {
    switch (_selectedRole) {
      case UserRole.ibuBalita:
        return Column(
          children: [
            _inputField(
              controller: _childNameCtrl,
              icon: Icons.child_care_rounded,
              hint: 'Nama Balita (Opsional)',
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _childAgeCtrl,
              icon: Icons.cake_outlined,
              hint: 'Usia Balita (Bulan, e.g. 18)',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final age = int.tryParse(v.trim());
                if (age == null) return 'Masukkan angka';
                if (age < 0 || age > 60) return 'Rentang 0-60 bulan';
                return null;
              },
            ),
          ],
        );
      case UserRole.ibuHamil:
        return _inputField(
          controller: _pregnancyWeekCtrl,
          icon: Icons.calendar_month_outlined,
          hint: 'Usia Kehamilan (Minggu, e.g. 24)',
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Usia kehamilan wajib diisi';
            }
            final week = int.tryParse(v.trim());
            if (week == null) return 'Masukkan angka';
            if (week < 1 || week > 45) return 'Rentang 1-45 minggu';
            return null;
          },
        );
      case UserRole.kaderPosyandu:
        return _inputField(
          controller: _posyanduNameCtrl,
          icon: Icons.location_city_outlined,
          hint: 'Nama Posyandu / Desa Wilayah Tugas',
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Nama Posyandu wajib diisi'
              : null,
        );
    }
  }

  Widget _buildPasswordStrengthIndicator() {
    final strength = _calculatePasswordStrength(_passCtrl.text);
    if (_passCtrl.text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(strength),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _getStrengthLabel(strength),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStrengthColor(strength),
                ),
              ),
            ],
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
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
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
        keyboardType: keyboardType,
        onChanged: onChanged,
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
