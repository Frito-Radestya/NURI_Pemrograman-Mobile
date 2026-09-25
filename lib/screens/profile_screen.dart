import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_model.dart';
import '../services/app_settings_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'child_list_screen.dart';
import 'food_diary_screen.dart';
import 'login_screen.dart';

/// Halaman Profil & Pengaturan (layer wajib yang sebelumnya belum ada).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _settings = AppSettingsService();

  UserModel? get _user => AuthService().currentUser;

  Future<void> _editProfile() async {
    final user = _user;
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.name);
    final contactCtrl = TextEditingController(text: user.emailOrPhone);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama wajib diisi'
                    : null,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contactCtrl,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Kontak wajib diisi'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Email / No. WhatsApp',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved == true) {
      AuthService().updateProfile(
        name: nameCtrl.text,
        emailOrPhone: contactCtrl.text,
      );
      if (mounted) setState(() {});
    }
    nameCtrl.dispose();
    contactCtrl.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari NURI?'),
        content: const Text(
          'Data simulasi tetap tersimpan selama aplikasi berjalan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      AuthService().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang NURI'),
        content: const Text(
          'NURI membantu keluarga dan kader Posyandu memantau gizi dan risiko stunting. '
          'Data pada versi coursework ini merupakan data simulasi lokal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Profil & Pengaturan'),
      ),
      body: user == null
          ? const Center(child: Text('Silakan masuk terlebih dahulu.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _profileCard(user),
                const SizedBox(height: 20),
                _sectionTitle('Data Saya'),
                _card([
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Data Anak'),
                    subtitle: const Text('Kelola data tumbuh kembang'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChildListScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('Food Diary'),
                    subtitle: const Text('Catat Asupan Harian'),

                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodDiaryScreen(),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                _sectionTitle('Pengaturan'),
                _card([
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Pengingat Harian'),
                    subtitle: const Text('Ringkasan gizi setiap pagi'),
                    value: _settings.dailyReminder,
                    activeThumbColor: AppColors.primary,
                    onChanged: _settings.setDailyReminder,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.restaurant_outlined),
                    title: const Text('Pengingat Makan'),
                    subtitle: const Text('Pengingat waktu makan balita'),
                    value: _settings.mealReminder,
                    activeThumbColor: AppColors.primary,
                    onChanged: _settings.setMealReminder,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_outlined),
                    title: const Text('Suara Notifikasi'),
                    value: _settings.soundEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: _settings.setSoundEnabled,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.show_chart_rounded),
                    title: const Text('Tampilkan Kurva Tumbuh'),
                    value: _settings.showGrowthChart,
                    activeThumbColor: AppColors.primary,
                    onChanged: _settings.setShowGrowthChart,
                  ),
                ]),
                const SizedBox(height: 20),
                _sectionTitle('Lainnya'),
                _card([
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Tentang NURI'),
                    onTap: _showAbout,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Keluar Akun',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: _logout,
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _profileCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: Colors.white24,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              user.avatarUrl ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 34, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.roleDisplayTitle} · ${user.emailOrPhone}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _editProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Edit Profil'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
