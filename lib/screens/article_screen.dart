import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class KnowledgeArticle {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> sections;

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
  });
}

class KnowledgeBase {
  static const articles = <KnowledgeArticle>[
    KnowledgeArticle(
      id: 'stunting',
      title: 'Mengenal Stunting',
      subtitle: 'Definisi, penyebab, dan tanda awal',
      icon: Icons.medical_services_outlined,
      sections: [
        'Stunting adalah gagal tumbuh yang ditandai tinggi badan lebih pendek dibandingkan standar usia dan jenis kelamin yang sama.',
        'Penyebab utamanya kekurangan gizi kronis, infeksi berulang, sanitasi buruk, serta pemberian MPASI yang tidak tepat.',
        'Tanda yang perlu dipantau: berat dan tinggi tidak naik sesuai kurva, perkembangan terlambat, dan anak sering sakit.',
        'Pemeriksaan rutin di Posyandu membantu menemukan risiko lebih awal.',
      ],
    ),
    KnowledgeArticle(
      id: 'who-growth',
      title: 'Standar Pertumbuhan WHO',
      subtitle: 'Mengenal kurva berat dan tinggi badan',
      icon: Icons.insights_outlined,
      sections: [
        'Standar WHO Child Growth Standards menjadi acuan pertumbuhan balita usia 0 sampai 59 bulan.',
        'Gunakan berat badan menurut panjang badan, tinggi badan menurut usia, dan lingkar kepala.',
        'Nilai di bawah minus dua standar deviasi menandakan kondisi pendek atau stunted.',
        'Data anak pada modul Data Anak dapat dibandingkan dengan kurva ini saat pemeriksaan berikutnya.',
      ],
    ),
    KnowledgeArticle(
      id: 'mpasi',
      title: 'Mengenal MPASI',
      subtitle: 'Makanan pendamping ASI',
      icon: Icons.restaurant_menu,
      sections: [
        'MPASI adalah makanan pendamping ASI yang mulai diberikan saat bayi mencapai usia enam bulan.',
        'ASI eksklusif diberikan sampai usia enam bulan dan dilanjutkan sampai dua tahun atau lebih.',
        'Tekstur MPASI dimulai dari bubur halus, bubur kasar, lalu makanan keluarga.',
        'Prioritaskan bahan alami kaya protein, zat besi, zink, serta keberagaman rasa.',
      ],
    ),
    KnowledgeArticle(
      id: 'mpasi-guide',
      title: 'Panduan MPASI',
      subtitle: 'Checklist menyiapkan MPASI',
      icon: Icons.assignment_outlined,
      sections: [
        'Cuci tangan dan bersihkan alat sebelum menyiapkan makanan.',
        'Masak hingga matang dan sajikan dalam wadah yang bersih. Jangan menyimpan sisa MPASI lebih dari dua jam.',
        'Perhatikan reaksi alergi saat memberi telur, ikan, dan kacang-kacangan secara bertahap.',
        'Catat jenis makanan dan reaksi pada catatan anak agar kader dapat memberi saran.',
      ],
    ),
    KnowledgeArticle(
      id: 'balanced-menu',
      title: 'Menu Gizi Seimbang',
      subtitle: 'Isi piring yang seimbang',
      icon: Icons.medication_outlined,
      sections: [
        'Piring makan sebaiknya terdiri dari sumber karbohidrat, protein, sayur, buah, dan lemak.',
        'Kombinasikan protein hewani dan protein nabati agar kebutuhan asam amino terpenuhi.',
        'Kurangi garam, gula, dan minyak goreng, serta perbanyak air putih.',
        'Catat asupan setiap hari melalui Food Diary untuk melihat persentase AKG.',
      ],
    ),
    KnowledgeArticle(
      id: 'news',
      title: 'Menuhi Janji Tangani Stunting',
      subtitle: 'Ringkasan program dan berita stunting',
      icon: Icons.newspaper_outlined,
      sections: [
        'Kementerian Kesehatan RI mendorong percepatan penanganan stunting melalui intervensi terpadu.',
        'ASI eksklusif, pemberian MPASI tepat, sanitasi, dan pengasuhan baik membentuk lingkungan tumbuh yang baik.',
        'Pemantauan rutin dan rujukan dini ke Yankes membantu penanganan risiko lebih cepat.',
        'Versi aplikasi ini menyertakan materi pendidikan ringkas untuk anggota kelompok.',
      ],
    ),
    KnowledgeArticle(
      id: 'consultation',
      title: 'Konsultasi Dokter',
      subtitle: 'Kapan perlu rujuk ke Puskesmas',
      icon: Icons.medical_information_outlined,
      sections: [
        'Konsultasi dengan kader atau tenaga kesehatan bila ada keraguan mengenai pertumbuhan atau gizi anak.',
        'Rujuk ke Puskesmas atau rumah sakit bila berat badannya tidak bertambah, sering muntah, atau tidak aktif.',
        'Simpan catatan berat, tinggi, dan keluhan utama agar mudah diperiksa tenaga kesehatan.',
        'NURI merupakan alat skrining awal dan bukan pengganti diagnosis dokter.',
      ],
    ),
  ];

  static KnowledgeArticle? byId(String id) {
    for (final article in articles) {
      if (article.id == id) return article;
    }
    return null;
  }
}

class ArticleScreen extends StatelessWidget {
  final String articleId;

  const ArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final article = KnowledgeBase.byId(articleId);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          article?.title ?? 'Artikel',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: article == null
          ? const Center(child: Text('Artikel tidak ditemukan.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Icon(
                          article.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              article.subtitle,
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
                const SizedBox(height: 16),
                for (var i = 0; i < article.sections.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.softGreen,
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            article.sections[i],
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.textDark,
                            ),
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

class ArticleSearchDelegate extends SearchDelegate<KnowledgeArticle?> {
  @override
  String get searchFieldLabel => 'Cari stunting, MPASI, gizi...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final q = query.trim().toLowerCase();
    final matches = KnowledgeBase.articles
        .where(
          (article) =>
              q.isEmpty ||
              article.title.toLowerCase().contains(q) ||
              article.subtitle.toLowerCase().contains(q),
        )
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final article = matches[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.softGreen,
            child: Icon(article.icon, color: AppColors.primaryDark),
          ),
          title: Text(article.title),
          subtitle: Text(article.subtitle),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleScreen(articleId: article.id),
              ),
            );
          },
        );
      },
    );
  }
}
