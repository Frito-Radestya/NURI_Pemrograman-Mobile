import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({
    super.key,
    required this.subjectLabel,
    this.pregnancyMode = false,
  });

  final String subjectLabel;
  final bool pregnancyMode;

  @override
  ConsumerState<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  late Set<String> _selected;
  int _selectedTrimester = 1;

  static const _menusChild = [
    _MenuIdea(
      id: 'menu_nasi_tim',
      title: 'Nasi tim ikan kembung & sayur',
      subtitle: 'Protein hewani, zat besi, dan karbohidrat dalam satu mangkuk.',
      image: 'assets/images/food_rice.jpg',
      kcal: 420,
      protein: 24,
      minutes: 25,
      tags: ['Tinggi protein', 'Zat besi'],
      ingredients: [
        '100 g nasi',
        '50 g ikan kembung, suwir',
        '30 g wortel, potong kecil',
        '20 g buncis, iris',
        '1 sdt minyak',
        'Air secukupnya',
      ],
      steps: [
        'Masak nasi dengan air lebih banyak hingga lembut.',
        'Kukus wortel dan buncis sampai empuk.',
        'Campur ikan kembung yang sudah dikukus dan disuwir.',
        'Tambahkan minyak, aduk rata, dan sajikan hangat.',
      ],
    ),
    _MenuIdea(
      id: 'menu_sup_bola',
      title: 'Sup bola daging & wortel',
      subtitle: 'Hangat, lembut, dan kaya protein untuk makan siang.',
      image: 'assets/images/food_soup.jpg',
      kcal: 380,
      protein: 21,
      minutes: 30,
      tags: ['Protein hewani', 'Mudah dikunyah'],
      ingredients: [
        '60 g daging sapi giling',
        '30 g wortel, potong bulat',
        '20 g buncis',
        '1 siung bawang putih',
        '500 ml air kaldu',
        '1 sdt minyak',
      ],
      steps: [
        'Bentuk daging giling menjadi bola-bola kecil.',
        'Didihkan air kaldu bersama bawang putih.',
        'Masukkan bola daging dan wortel, masak hingga matang.',
        'Tambahkan buncis, masak sebentar, lalu sajikan.',
      ],
    ),
    _MenuIdea(
      id: 'menu_opor_telur',
      title: 'Opor telur & tempe',
      subtitle: 'Sumber protein terjangkau dengan rasa gurih alami.',
      image: 'assets/images/food_egg.jpg',
      kcal: 410,
      protein: 22,
      minutes: 20,
      tags: ['Protein', 'Ekonomis'],
      ingredients: [
        '1 butir telur ayam',
        '50 g tempe, potong kecil',
        '100 ml santan encer',
        '1 lembar daun salam',
        'Bawang merah & bawang putih',
        'Sedikit garam',
      ],
      steps: [
        'Rebus telur, kupas, lalu belah dua.',
        'Tumis bawang dan daun salam hingga harum.',
        'Masukkan santan, tempe, dan telur.',
        'Masak dengan api kecil hingga bumbu meresap.',
      ],
    ),
  ];

  static const _menusT1 = [
    _MenuIdea(
      id: 'menu_t1_sup_ayam',
      title: 'Sup Bening Ayam & Sayur (TM 1)',
      subtitle:
          'Hangat, mudah dicerna saat mual, kaya vitamin B6 dan asam folat.',
      image: 'assets/images/food_soup.jpg',
      kcal: 360,
      protein: 22,
      minutes: 25,
      tags: ['Anti Mual', 'Asam Folat', 'TM 1'],
      ingredients: [
        '70 g daging ayam kampung suwir',
        '30 g wortel potong dadu',
        '20 g brokoli hijau',
        '1 batang daun seledri',
        'Kuah kaldu jahe hangat',
      ],
      steps: [
        'Rebus ayam bersama jahe geprek untuk mengurangi sensasi mual.',
        'Masukkan sayuran wortel dan brokoli, masak hingga matang lembut.',
        'Sajikan dalam porsi kecil namun sering (5–6 kali sehari).',
      ],
    ),
    _MenuIdea(
      id: 'menu_t1_bubur_ijo',
      title: 'Bubur Kacang Hijau Kuah Jahe (TM 1)',
      subtitle:
          'Kaya asam folat alami untuk mencegah cacat tabung saraf janin.',
      image: 'assets/images/food_rice.jpg',
      kcal: 340,
      protein: 14,
      minutes: 30,
      tags: ['Asam Folat', 'Serat Lembut', 'TM 1'],
      ingredients: [
        '60 g kacang hijau rendam',
        '2 ruas jahe memar',
        '100 ml santan encer',
        'Sedikit gula aren',
      ],
      steps: [
        'Rebus kacang hijau hingga empuk dan pecah sempurna.',
        'Masukkan santan encer dan jahe, aduk rata dengan api kecil.',
        'Nikmati selagi hangat sebagai selingan sarapan atau sore.',
      ],
    ),
  ];

  static const _menusT2 = [
    _MenuIdea(
      id: 'menu_t2_nasi_tim_ikan',
      title: 'Nasi Tim Ikan Kembung & Bayam (TM 2)',
      subtitle:
          'Zat besi dan kalsium tinggi untuk pembentukan tulang & organ janin.',
      image: 'assets/images/food_rice.jpg',
      kcal: 440,
      protein: 26,
      minutes: 25,
      tags: ['Tinggi Kalsium', 'Zat Besi', 'TM 2'],
      ingredients: [
        '100 g nasi pulen lembut',
        '60 g ikan kembung kukus suwir',
        '30 g daun bayam hijau',
        '1 sdt minyak kelapa',
      ],
      steps: [
        'Kukus ikan kembung bersama irisan bawang putih dan kunyit.',
        'Rebus daun bayam sebentar agar warna dan nutrisinya utuh.',
        'Campur nasi tim dengan suwiran ikan dan bayam hangat.',
      ],
    ),
    _MenuIdea(
      id: 'menu_t2_opor_telur',
      title: 'Opor Telur Ayam & Tempe Bacem (TM 2)',
      subtitle: 'Kombinasi protein hewani dan nabati dengan tambahan energi +300 kkal.',
      image: 'assets/images/food_egg.jpg',
      kcal: 430,
      protein: 24,
      minutes: 20,
      tags: ['+300 kkal', 'Protein Hewani', 'TM 2'],
      ingredients: [
        '1 butir telur ayam rebus',
        '50 g tempe kedelai',
        '100 ml santan sedang',
        'Daun salam & serai geprek',
      ],
      steps: [
        'Tumis bumbu opor kuning bersama serai dan daun salam.',
        'Tuang santan perlahan, masukkan potongan tempe dan telur rebus.',
        'Masak hingga kuah mengental dan bumbu meresap sempurna.',
      ],
    ),
  ];

  static const _menusT3 = [
    _MenuIdea(
      id: 'menu_t3_bola_daging',
      title: 'Sup Bola Daging Sapi & Brokoli (TM 3)',
      subtitle:
          'Zat besi tinggi untuk persiapan persalinan & pematangan paru janin.',
      image: 'assets/images/food_soup.jpg',
      kcal: 460,
      protein: 28,
      minutes: 30,
      tags: ['Cegah Anemia', 'Persiapan Lahir', 'TM 3'],
      ingredients: [
        '70 g daging sapi giling segar',
        '40 g kuntum brokoli kukus',
        '1 butir telur puyuh rebus',
        'Air kaldu gurih berempah',
      ],
      steps: [
        'Bentuk daging giling menjadi bola-bola lembut.',
        'Rebus dalam kaldu mendidih hingga bola daging mengapung.',
        'Masukkan brokoli dan telur puyuh, sajikan hangat berkuah.',
      ],
    ),
    _MenuIdea(
      id: 'menu_t3_ikan_bakar',
      title: 'Ikan Bakar Bumbu Kuning & Lalap (TM 3)',
      subtitle: 'Kaya DHA dan asam lemak omega-3 untuk retina & otak janin.',
      image: 'assets/images/food_egg.jpg',
      kcal: 430,
      protein: 27,
      minutes: 25,
      tags: ['DHA & Omega-3', 'Persiapan ASI', 'TM 3'],
      ingredients: [
        '80 g ikan laut kembung/tongkol',
        'Perasan jeruk nipis & kunyit',
        'Lalapan labu siam kukus & tomat',
      ],
      steps: [
        'Lumuri ikan dengan perasan jeruk nipis dan bumbu kuning.',
        'Bakar di atas pemanggang atau wajan antilengket hingga harum.',
        'Sajikan bersama lalapan labu siam kukus yang kaya serat.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = {...ref.read(appControllerProvider).mealPlan};
    if (widget.pregnancyMode) {
      final activePreg = ref.read(appControllerProvider).activePregnancy;
      if (activePreg != null) {
        final prog = PregnancyCalculator.progress(
          hpht: activePreg.hpht,
          hpl: activePreg.hpl,
        );
        _selectedTrimester = prog.trimester;
      }
    }
  }

  void _save() {
    ref.read(appControllerProvider.notifier).setMealPlan(_selected.toList());
    showNuriSnack(context, 'Rencana makan disimpan.');
  }

  List<_MenuIdea> get _currentMenus {
    if (!widget.pregnancyMode) return _menusChild;
    switch (_selectedTrimester) {
      case 1:
        return _menusT1;
      case 2:
        return _menusT2;
      case 3:
      default:
        return _menusT3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menus = _currentMenus;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Rekomendasi menu',
              subtitle: 'Untuk ${widget.subjectLabel}',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroBanner(pregnancyMode: widget.pregnancyMode),
                    if (widget.pregnancyMode) ...[
                      const SizedBox(height: 14),
                      NuriSegmentedControl<int>(
                        values: const [1, 2, 3],
                        selected: _selectedTrimester,
                        labelFor: (t) => 'Trimester $t',
                        onChanged: (t) =>
                            setState(() => _selectedTrimester = t),
                      ),
                      const SizedBox(height: 12),
                      _TrimesterGuideCard(trimester: _selectedTrimester),
                    ],
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: widget.pregnancyMode
                          ? 'Menu Trimester $_selectedTrimester'
                          : 'Menu hari ini',
                      subtitle: 'Pilih menu yang ingin dicoba minggu ini.',
                    ),
                    const SizedBox(height: 10),
                    ...menus.map(
                      (menu) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MenuCard(
                          menu: menu,
                          selected: _selected.contains(menu.id),
                          onToggle: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (!_selected.remove(menu.id)) {
                                _selected.add(menu.id);
                              }
                            });
                          },
                          onRecipe: () => _showRecipe(menu),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    NuriButton(
                      label: 'Simpan rencana makan',
                      icon: Icons.check_rounded,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 22),
                    SectionHeader(
                      title: 'Standar porsi',
                      subtitle: widget.pregnancyMode
                          ? 'Tambahan kebutuhan ibu hamil'
                          : 'Panduan umum usia 1–3 tahun',
                    ),
                    const SizedBox(height: 10),
                    _PortionGuide(pregnancyMode: widget.pregnancyMode),
                    const SizedBox(height: 20),
                    const SectionHeader(
                      title: 'Piring 4 bintang',
                      subtitle: 'Empat kelompok makanan dalam satu piring.',
                    ),
                    const SizedBox(height: 10),
                    const _FourStarGrid(),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Cara menyusun'),
                    const SizedBox(height: 10),
                    const _StepsCard(),
                    const SizedBox(height: 12),
                    InfoBanner(
                      title: widget.pregnancyMode
                          ? 'Perhatikan selama hamil'
                          : 'Perhatikan saat memberi makan',
                      body: widget.pregnancyMode
                          ? 'Hindari makanan mentah atau setengah matang, batasi kafein, dan minum TTD setiap hari.'
                          : 'Hindari madu untuk anak di bawah 1 tahun, batasi gula/garam, dan sesuaikan tekstur dengan usia.',
                      icon: Icons.health_and_safety_outlined,
                      background: AppColors.peachSoft,
                      foreground: AppColors.coral,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sumber: ${AkgReference.sourceLabel} & TKPI 2017.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipe(_MenuIdea menu) {
    showNuriSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NuriImage(
              asset: menu.image,
              width: double.infinity,
              height: 160,
              radius: 16,
            ),
            const SizedBox(height: 14),
            Text(menu.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              menu.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _RecipeMetric(
                  icon: Icons.local_fire_department_rounded,
                  value: '${menu.kcal} kkal',
                ),
                _RecipeMetric(
                  icon: Icons.fitness_center_rounded,
                  value: '${menu.protein} g protein',
                ),
                _RecipeMetric(
                  icon: Icons.schedule_rounded,
                  value: '${menu.minutes} menit',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bahan',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            ...menu.ingredients.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 13.5, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Cara membuat',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            ...List.generate(
              menu.steps.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        menu.steps[index],
                        style: const TextStyle(fontSize: 13.5, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const NuriDisclaimer(compact: true),
            const SizedBox(height: 8),
            NuriButton(
              label: 'Tutup',
              variant: NuriButtonVariant.outlined,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrimesterGuideCard extends StatelessWidget {
  const _TrimesterGuideCard({required this.trimester});

  final int trimester;

  @override
  Widget build(BuildContext context) {
    final (title, focus, tip) = switch (trimester) {
      1 => (
        'Fokus Trimester 1: Asam Folat & Atasi Mual',
        'Pembentukan tabung saraf dan organ vital janin (cegah anensefali & spina bifida).',
        'Makan dalam porsi kecil tapi sering (5–6x sehari), pilih makanan hangat yang tidak berbau tajam, dan perbanyak vitamin B6.',
      ),
      2 => (
        'Fokus Trimester 2: Pertumbuhan Tulang & Organ',
        'Pertumbuhan pesat janin membutuhkan tambahan energi +300 kkal dan protein hewani tinggi.',
        'Pastikan lauk ikan kembung, telur, atau daging selalu ada untuk mencegah Berat Badan Lahir Rendah (BBLR).',
      ),
      _ => (
        'Fokus Trimester 3: Otak Janin & Persiapan ASI',
        'Pematangan otak dan cadangan zat besi janin, serta persiapan laktasi Ibu.',
        'Penuhi asam lemak DHA (ikan laut), zat besi tinggi cegah anemia saat bersalin, dan serat tinggi untuk cegah sembelit.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            focus,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuIdea {
  const _MenuIdea({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.kcal,
    required this.protein,
    required this.minutes,
    required this.tags,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String title;
  final String subtitle;
  final String image;
  final int kcal;
  final int protein;
  final int minutes;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> steps;
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.pregnancyMode});

  final bool pregnancyMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.peachSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregnancyMode ? 'Gizi ibu hamil' : 'Gizi balita',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pregnancyMode
                ? 'Makan untuk dua, bukan dua porsi.'
                : 'Piring kecil, gizi lengkap.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pregnancyMode
                ? 'Tambahkan protein hewani, sayur hijau, buah, dan cukup air setiap hari.'
                : 'Setiap makan usahakan ada makanan pokok, protein hewani, sayur, dan buah.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.menu,
    required this.selected,
    required this.onToggle,
    required this.onRecipe,
  });

  final _MenuIdea menu;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onRecipe;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      borderColor: selected ? AppColors.primary : AppColors.line,
      color: selected ? AppColors.mint : AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              NuriImage(asset: menu.image, width: 84, height: 84, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            menu.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14.5,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onToggle,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.muted,
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menu.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: menu.tags
                          .map(
                            (tag) => Pill(
                              label: tag,
                              background: AppColors.surfaceSubtle,
                              foreground: AppColors.text,
                              fontSize: 11,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 15,
                color: AppColors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                '${menu.kcal} kkal',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.fitness_center_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${menu.protein} g protein',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const Spacer(),
              TextButton(
                onPressed: onRecipe,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Lihat resep'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeMetric extends StatelessWidget {
  const _RecipeMetric({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortionGuide extends StatelessWidget {
  const _PortionGuide({required this.pregnancyMode});

  final bool pregnancyMode;

  @override
  Widget build(BuildContext context) {
    final items = pregnancyMode
        ? const [
            (
              'Energi',
              'Tambahan ±300 kkal pada trimester 2–3',
              Icons.local_fire_department_rounded,
              AppColors.amber,
            ),
            (
              'Protein',
              '70–85 g per hari',
              Icons.fitness_center_rounded,
              AppColors.coral,
            ),
            (
              'Zat besi',
              '18 mg per hari + TTD 90 tablet',
              Icons.medication_rounded,
              AppColors.primary,
            ),
            (
              'Cairan',
              '±2,3 liter per hari',
              Icons.water_drop_rounded,
              AppColors.blue,
            ),
          ]
        : const [
            (
              'Makanan pokok',
              '100 g nasi / 2–3 kali sehari',
              Icons.rice_bowl_rounded,
              AppColors.amber,
            ),
            (
              'Protein hewani',
              '35 g ikan/telur/ayam per hari',
              Icons.fitness_center_rounded,
              AppColors.coral,
            ),
            (
              'Sayur & buah',
              '50 g sayur + 50 g buah',
              Icons.eco_rounded,
              AppColors.primary,
            ),
            (
              'Lemak tambahan',
              '5 g minyak / santan secukupnya',
              Icons.water_drop_rounded,
              AppColors.blue,
            ),
          ];
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: items[i].$4.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(items[i].$3, size: 18, color: items[i].$4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].$1,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          items[i].$2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _FourStarGrid extends StatelessWidget {
  const _FourStarGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Makanan pokok',
        'Nasi, kentang, jagung',
        Icons.rice_bowl_rounded,
        AppColors.amber,
      ),
      (
        'Protein hewani',
        'Ikan, telur, ayam, hati',
        Icons.set_meal_rounded,
        AppColors.coral,
      ),
      ('Sayur', 'Bayam, wortel, buncis', Icons.eco_rounded, AppColors.primary),
      ('Buah', 'Pisang, pepaya, jeruk', Icons.apple_rounded, AppColors.blue),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.7,
      children: items.map((item) {
        return AppCard(
          padding: const EdgeInsets.all(12),
          radius: 15,
          child: Row(
            children: [
              Icon(item.$3, size: 22, color: item.$4),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Isi setengah piring dengan sayur dan buah.',
      'Sisakan seperempat untuk makanan pokok.',
      'Isi seperempat lagi dengan protein hewani.',
      'Tambahkan sedikit lemak sehat dan air putih.',
    ];
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: List.generate(steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[index],
                    style: const TextStyle(fontSize: 13, height: 1.45),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
