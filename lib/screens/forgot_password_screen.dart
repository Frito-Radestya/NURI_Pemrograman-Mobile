import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/wave_header.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputCtrl = TextEditingController();
  bool _isEmailMethod = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final contact = _inputCtrl.text.trim();
      await AuthService().sendOtp(contact);
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpVerificationScreen(contact: contact, isFromRegister: false),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengirim OTP: $e')));
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
              height: MediaQuery.of(context).size.height * 0.35,
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
                          const AppLogo(size: 64, white: true),
                          const SizedBox(height: 10),
                          Text(
                            'LUPA KATA SANDI',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Pemulihan Akses Akun NURI',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
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
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Metode Pemulihan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masukkan email atau nomor WhatsApp terdaftar untuk menerima kode verifikasi OTP.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEmailMethod = true;
                                  _inputCtrl.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _isEmailMethod
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isEmailMethod
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 18,
                                      color: _isEmailMethod
                                          ? AppColors.primary
                                          : AppColors.textGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Email',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: _isEmailMethod
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _isEmailMethod
                                            ? AppColors.primary
                                            : AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEmailMethod = false;
                                  _inputCtrl.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isEmailMethod
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_isEmailMethod
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 18,
                                      color: !_isEmailMethod
                                          ? AppColors.primary
                                          : AppColors.textGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'WhatsApp',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: !_isEmailMethod
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: !_isEmailMethod
                                            ? AppColors.primary
                                            : AppColors.textGrey,
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
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextFormField(
                        controller: _inputCtrl,
                        keyboardType: _isEmailMethod
                            ? TextInputType.emailAddress
                            : TextInputType.phone,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) {
                            return _isEmailMethod
                                ? 'Email tidak boleh kosong'
                                : 'Nomor WhatsApp tidak boleh kosong';
                          }
                          if (_isEmailMethod) {
                            final emailPattern = RegExp(
                              r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
                            );
                            if (!emailPattern.hasMatch(value)) {
                              return 'Format email belum benar';
                            }
                          } else {
                            final phonePattern = RegExp(r'^0\d{8,14}$');
                            if (!phonePattern.hasMatch(value)) {
                              return 'Gunakan format 08xxxxxxxxxx';
                            }
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Icon(
                            _isEmailMethod
                                ? Icons.mail_outline_rounded
                                : Icons.phone_android_rounded,
                            color: AppColors.textGrey,
                          ),
                          hintText: _isEmailMethod
                              ? 'Masukkan Email Terdaftar'
                              : 'Masukkan No. WhatsApp (08...)',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kode OTP 4-digit akan dikirim secara resmi oleh sistem NURI.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textDark,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
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
                          onPressed: _isLoading ? null : _handleSendOtp,
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
                                  'KIRIM KODE OTP',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
