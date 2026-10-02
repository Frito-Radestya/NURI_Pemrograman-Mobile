import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/wave_header.dart';
import 'login_screen.dart';
import 'mpasi_menu_screen.dart';
import 'food_diary_screen.dart';
import 'food_scan_screen.dart';
import 'stunting_screening_screen.dart';
import 'growth_curve_screen.dart';
import 'chatbot_screen.dart';
import 'screening_session_screen.dart';
import 'child_list_screen.dart';
import 'profile_screen.dart';
import 'article_screen.dart';

/// Status implementasi fitur, selaras PRD §5 kolom Status.
enum HomeFeatureStatus { ready, partial, soon }

class _HomeFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final HomeFeatureStatus status;
  final String prdRef;
  final String? articleId;

  const _HomeFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
    required this.prdRef,
    this.articleId,
  });
}

List<_HomeFeature> _featuresForRole(UserRole? role) {
  switch (role) {
    case UserRole.kaderPosyandu:
      return const [
        _HomeFeature(
          title: 'Data Anak',
          subtitle: 'Kelola + ukur BB/TB',
          icon: Icons.child_care,
          color: Color(0xFFAB47BC),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Data anak (Parsial)',
        ),
        _HomeFeature(
          title: 'Skrining',
          subtitle: 'z-score WHO',
          icon: Icons.medical_services_outlined,
          color: Color(0xFF00C9A7),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Skrining z-score (Parsial: manual, foto eksperimental)',
        ),
        _HomeFeature(
          title: 'Rekap Sesi',
          subtitle: 'Sesi + rekap kader',
          icon: Icons.assessment_outlined,
          color: Color(0xFF2F80ED),
          status: HomeFeatureStatus.soon,
          prdRef: 'PRD §5 Mode kader (Parsial: data ada, rekap belum)',
        ),
        _HomeFeature(
          title: 'Food Diary',
          subtitle: 'Catat asupan',
          icon: Icons.menu_book_rounded,
          color: Color(0xFFFF8A65),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Food diary (Parsial)',
        ),
        _HomeFeature(
          title: 'Edukasi',
          subtitle: 'Stunting + WHO',
          icon: Icons.school_outlined,
          color: Color(0xFF26C6DA),
          status: HomeFeatureStatus.ready,
          prdRef: 'Artikel pengetahuan',
          articleId: 'stunting',
        ),
        _HomeFeature(
          title: 'MPASI',
          subtitle: 'Resep bergizi',
          icon: Icons.favorite,
          color: Color(0xFFFF6B6B),
          status: HomeFeatureStatus.ready,
          prdRef: 'Pendukung F-06',
        ),
      ];
    case UserRole.ibuHamil:
      return const [
        _HomeFeature(
          title: 'Food Diary',
          subtitle: 'Catat asupan',
          icon: Icons.menu_book_rounded,
          color: Color(0xFFFF8A65),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Food diary (Parsial)',
        ),
        _HomeFeature(
          title: 'MPASI',
          subtitle: 'Persiapan bergizi',
          icon: Icons.favorite,
          color: Color(0xFFFF6B6B),
          status: HomeFeatureStatus.ready,
          prdRef: 'Pendukung F-06',
        ),
        _HomeFeature(
          title: 'AKG Hamil',
          subtitle: 'Monitoring v2',
          icon: Icons.pregnant_woman_rounded,
          color: Color(0xFFFF7043),
          status: HomeFeatureStatus.soon,
          prdRef: 'PRD §5 Mode ibu hamil v2 (Belum)',
        ),
        _HomeFeature(
          title: 'Data Anak',
          subtitle: 'Kelola tumbuh',
          icon: Icons.child_care,
          color: Color(0xFFAB47BC),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Data anak (Parsial)',
        ),
        _HomeFeature(
          title: 'Edukasi',
          subtitle: 'Gizi + stunting',
          icon: Icons.school_outlined,
          color: Color(0xFF26C6DA),
          status: HomeFeatureStatus.ready,
          prdRef: 'Artikel pengetahuan',
          articleId: 'balanced-menu',
        ),
      ];
    case UserRole.ibuBalita:
    default:
      return const [
        _HomeFeature(
          title: 'Scan Makanan',
          subtitle: 'Foto + gizi',
          icon: Icons.photo_camera_outlined,
          color: Color(0xFF2F80ED),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Scan multi-objek (Parsial: single + koreksi manual)',
        ),
        _HomeFeature(
          title: 'Food Diary',
          subtitle: '4 sesi + ring',
          icon: Icons.menu_book_rounded,
          color: Color(0xFFFF8A65),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Food diary (Parsial)',
        ),
        _HomeFeature(
          title: 'Data Anak',
          subtitle: 'BB/TB + status',
          icon: Icons.child_care,
          color: Color(0xFFAB47BC),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Data anak (Parsial)',
        ),
        _HomeFeature(
          title: 'Kurva',
          subtitle: 'WHO + tren',
          icon: Icons.show_chart_rounded,
          color: Color(0xFF00C9A7),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Kurva (Parsial)',
        ),
        _HomeFeature(
          title: 'MPASI',
          subtitle: 'Resep bergizi',
          icon: Icons.favorite,
          color: Color(0xFFFF6B6B),
          status: HomeFeatureStatus.ready,
          prdRef: 'Pendukung F-06',
        ),
        _HomeFeature(
          title: 'Edukasi',
          subtitle: 'Stunting + WHO',
          icon: Icons.school_outlined,
          color: Color(0xFF26C6DA),
          status: HomeFeatureStatus.ready,
          prdRef: 'Artikel pengetahuan',
          articleId: 'stunting',
        ),
        _HomeFeature(
          title: 'Tanya NURI',
          subtitle: 'Chatbot gizi',
          icon: Icons.chat_bubble_outline_rounded,
          color: Color(0xFF7C4DFF),
          status: HomeFeatureStatus.partial,
          prdRef: 'PRD §5 Chatbot Groq (Parsial: online bila ada key)',
        ),
      ];
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      _BerandaTab(),
      ChildListScreen(),
      FoodDiaryScreen(),
      MpasiMenuScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.child_care_outlined),
            selectedIcon: Icon(Icons.child_care_rounded),
            label: 'Anak',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'MPASI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _BerandaTab extends StatelessWidget {
  const _BerandaTab();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = user?.name ?? SampleData.userName;
    final displayAvatar = user?.avatarUrl ?? SampleData.avatarUrl;
    final displayRole = user?.roleDisplayTitle ?? 'Ibu Balita';
    final features = _featuresForRole(user?.role);

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
                        name: displayName,
                        avatarUrl: displayAvatar,
                        roleTitle: displayRole,
                        onProfileTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        onLogout: () {
                          AuthService().logout();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -24,
                  child: AppSearchBar(
                    hint: 'Apa itu stunting ?',
                    onTap: () => showSearch<void>(
                      context: context,
                      delegate: ArticleSearchDelegate(),
                    ),
                    onFilterTap: () => showSearch<void>(
                      context: context,
                      delegate: ArticleSearchDelegate(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _heroBanner(context),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _foodDiaryBanner(context),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionTitle('Fitur'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _featureGrid(context, features),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionTitle('Mengenal Stunting'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _stuntingCard(context),
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
                children: [_newsCard(context), _newsCard(context)],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _openArticle(BuildContext context, String articleId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleScreen(articleId: articleId)),
    );
  }

  void _openFeature(BuildContext context, _HomeFeature feature) {
    switch (feature.title) {
      case 'Scan Makanan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FoodScanScreen()),
        );
        break;
      case 'Data Anak':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChildListScreen()),
        );
        break;
      case 'Food Diary':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FoodDiaryScreen()),
        );
        break;
      case 'MPASI':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MpasiMenuScreen()),
        );
        break;
      case 'Edukasi':
        _openArticle(context, feature.articleId ?? 'stunting');
        break;
      case 'Tanya NURI':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        );
        break;
      case 'Skrining':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StuntingScreeningScreen(),
          ),
        );
        break;
      case 'Kurva':
        final uid = AuthService().currentUser?.id ?? 'guest';
        final kids = ChildService().getChildren(uid);
        if (kids.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StuntingScreeningScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GrowthCurveScreen(childId: kids.first.id),
            ),
          );
        }
        break;
      case 'Rekap Sesi':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ScreeningSessionScreen(),
          ),
        );
        break;
      default:
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(feature.title),
            content: Text(
              'Fitur ini ${feature.status == HomeFeatureStatus.soon ? "belum tersedia" : "sebagian tersedia"}.\n${feature.prdRef}.',
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
  }

  Widget _featureGrid(BuildContext context, List<_HomeFeature> features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final feature = features[i];
        final enabled = feature.status != HomeFeatureStatus.soon;
        return GestureDetector(
          onTap: () => _openFeature(context, feature),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: enabled
                    ? feature.color.withValues(alpha: 0.25)
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: (enabled ? feature.color : Colors.grey).withValues(
                      alpha: 0.15,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feature.icon,
                    color: enabled ? feature.color : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.status == HomeFeatureStatus.soon
                      ? 'Segera'
                      : feature.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _heroBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _openArticle(context, 'who-growth'),
      child: Container(
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
                    'Kurva WHO membantu orang tua mengenali risiko lebih awal.',
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
      ),
    );
  }

  Widget _foodDiaryBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FoodDiaryScreen()),
        );
      },
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8FFF8), Color(0xFFD0F5EE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Food Diary Hari Ini',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    'Catat asupan gizi harianmu sekarang',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stuntingCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openArticle(context, 'stunting'),
      child: Container(
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
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openArticle(context, 'news'),
      child: Container(
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    SampleData.newsImage,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(height: 110, color: AppColors.softBlue),
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
                'Pencegahan stunting dimulai dari ASI eksklusif dan MPASI bergizi',
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
                    onBackgroundImageError: (_, _) {},
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Diva Putri Adilla\nSep 9, 2025',
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
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF42A5F5),
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
