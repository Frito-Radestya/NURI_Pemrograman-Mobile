import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/sample_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/wave_header.dart';
import 'mpasi_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                WaveHeader(
                  height: 210,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: ProfileGreeting(
                        name: SampleData.userName,
                        avatarUrl: SampleData.avatarUrl,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -24,
                  child: const AppSearchBar(hint: 'Apa itu stunting ?'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _heroBanner(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _category(
                    context,
                    Icons.medical_services_outlined,
                    const Color(0xFF00C9A7),
                    'Mengenal\nStunting',
                  ),
                  _category(
                    context,
                    Icons.favorite,
                    const Color(0xFFFF6B6B),
                    'MPASI',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MpasiMenuScreen(),
                        ),
                      );
                    },
                  ),
                  _category(
                    context,
                    Icons.medication_outlined,
                    const Color(0xFF26C6DA),
                    'Menu Gizi\nSeimbang',
                  ),
                  _category(
                    context,
                    Icons.child_care,
                    const Color(0xFFAB47BC),
                    'Tumbuh\nKembang',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionTitle('Mengenal Stunting'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _stuntingCard(),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionTitle('Berita Tentang Kesehatan'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _newsCard(),
                  _newsCard(),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _heroBanner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            right: 60,
            child: Icon(Icons.add, size: 18, color: Colors.amber.shade200),
          ),
          Positioned(
            bottom: 30,
            right: 100,
            child: Icon(Icons.circle, size: 8, color: Colors.blue.shade100),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 110, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KETAHUI TINGGI DAN BERAT BADAN IDEAL ANAK MENURUT WHO',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1565C0),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Apakah Si Kecil masuk dalam kategori berat badan normal?',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.blueGrey.shade300,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Icon(
              Icons.health_and_safety,
              size: 88,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _category(
    BuildContext context,
    IconData icon,
    Color color,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.15,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stuntingCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFF5FBFC)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 8, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Definisi Mengenai Stunting',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stunting adalah kondisi gagal tumbuh pada anak akibat kekurangan gizi kronis.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      height: 1.4,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            child: Image.network(
              SampleData.doctorPhoto,
              width: 120,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                color: AppColors.softBlue,
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _newsCard() {
    return Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  SampleData.newsImage,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 110,
                    color: AppColors.softBlue,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                right: 10,
                child: Text(
                  'MENUHI JANJI TANGANI STUNTING DAN GIZI BURUK',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Text(
              'Feel the thrill on the only surf simulator in Maldives 2022',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage(SampleData.avatarUrl),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Diva Putri Adilla\nSep 9, 2022',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: AppColors.textGrey,
                      height: 1.2,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    size: 14,
                    color: Color(0xFF42A5F5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
