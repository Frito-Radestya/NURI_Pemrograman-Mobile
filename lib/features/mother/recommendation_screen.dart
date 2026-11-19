import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'recommendation_guide_widgets.dart';
import 'recommendation_menu_widgets.dart';

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
    MenuIdea(
      id: 'menu_nasi_tim',
      title: 'Nasi Tim Ikan Kembung & Sayur',
      subtitle:
          'Protein hewani, zat besi, dan karbohidrat dalam satu mangkuk lembut.',
      image: 'assets/images/food_rice.jpg',
      kcal: 420,
      protein: 24,
      minutes: 25,
      tags: ['Tinggi Protein', 'Zat Besi', 'Balita'],
      mealType: MealType.lunch,
      grams: 200,
      fatG: 12,
      carbG: 50,
      ironMg: 3.2,
      zincMg: 2.1,
      benefitNote:
          'Mendukung pacu tumbuh sel tulang dan otot anak usia 1–2 tahun.',
      ingredients: [
        '100 g nasi pulen lunak',
        '50 g ikan kembung kukus suwir',
        '30 g wortel potong dadu kecil',
        '20 g buncis muda iris',
        '1 sdt minyak kelapa / santan',
        'Kaldu ayam secukupnya',
      ],
      steps: [
        'Masak nasi dengan kaldu ayam hingga tekstur tim lembek.',
        'Kukus wortel dan buncis sampai empuk.',
        'Campur ikan kembung yang sudah dikukus dan disuwir bersih dari duri.',
        'Tambahkan minyak kelapa, aduk rata, dan sajikan hangat.',
      ],
    ),
    MenuIdea(
      id: 'menu_sup_bola',
      title: 'Sup Bola Daging & Wortel',
      subtitle: 'Hangat, lembut, dan kaya zat besi untuk makan siang balita.',
      image: 'assets/images/food_soup.jpg',
      kcal: 380,
      protein: 21,
      minutes: 30,
      tags: ['Protein Hewani', 'Mudah Dikunyah', 'Balita'],
      mealType: MealType.dinner,
      grams: 220,
      fatG: 14,
      carbG: 40,
      ironMg: 3.8,
      zincMg: 2.8,
      benefitNote: 'Zat besi hewani mudah diserap untuk mencegah stunting.',
      ingredients: [
        '60 g daging sapi giling segar',
        '30 g wortel potong bulat kecil',
        '20 g buncis potong',
        '1 siung bawang putih cincang',
        '500 ml air kaldu sapi alami',
        '1 sdt minyak',
      ],
      steps: [
        'Bentuk daging giling menjadi bola-bola kecil lembut.',
        'Didihkan air kaldu bersama tumisan bawang putih harum.',
        'Masukkan bola daging dan wortel, masak hingga matang.',
        'Tambahkan buncis, masak sebentar, lalu sajikan hangat.',
      ],
    ),
    MenuIdea(
      id: 'menu_opor_telur',
      title: 'Opor Telur & Tempe Gurih',
      subtitle: 'Sumber protein terjangkau dengan rasa gurih disukai anak.',
      image: 'assets/images/food_egg.jpg',
      kcal: 410,
      protein: 22,
      minutes: 20,
      tags: ['Protein Lengkap', 'Ekonomis', 'Balita'],
      mealType: MealType.breakfast,
      grams: 210,
      fatG: 16,
      carbG: 42,
      ironMg: 2.8,
      zincMg: 1.9,
      benefitNote:
          'Kuning telur mengandung kolin tinggi untuk perkembangan otak.',
      ingredients: [
        '1 butir telur ayam rebus',
        '50 g tempe potong dadu',
        '100 ml santan encer segar',
        '1 lembar daun salam & serai',
        'Bawang merah & bawang putih',
        'Sedikit garam beryodium',
      ],
      steps: [
        'Rebus telur hingga matang, kupas, dan belah dua.',
        'Tumis bawang merah, bawang putih, dan daun salam harum.',
        'Tuang santan encer, masukkan tempe dan telur rebus.',
        'Masak dengan api kecil hingga bumbu meresap gurih.',
      ],
    ),
  ];

  // -------------------------------------------------------------
  // MENUS TRIMESTER 1: Asam Folat 600 mcg, B6 Anti Mual, Porsi Kecil
  // -------------------------------------------------------------
  static const _menusT1 = [
    MenuIdea(
      id: 'menu_t1_oat_pisang',
      title: 'Oatmeal Pisang & Susu Kedelai Jahe',
      subtitle: 'Vitamin B6 pereda mual & asam folat alami untuk awal kehamilan.',
      image: 'assets/images/food_rice.jpg',
      kcal: 330,
      protein: 13,
      minutes: 15,
      tags: ['Sarapan', 'Anti Mual', 'Asam Folat', 'TM 1'],
      mealType: MealType.breakfast,
      grams: 220,
      fatG: 6,
      carbG: 56,
      ironMg: 2.9,
      zincMg: 1.6,
      benefitNote:
          'Vitamin B6 pada pisang & jahe menekan rasa mual pagi hari (morning sickness).',
      ingredients: [
        '40 g oat gandum instan',
        '1 buah pisang ambon matang iris',
        '150 ml susu kedelai hangat',
        '1 cm jahe parut peras airnya',
        '1 sdt madu murni (opsional)',
      ],
      steps: [
        'Seduh oat dengan susu kedelai hangat dan air perasan jahe.',
        'Aduk rata hingga oat mengembang lembut.',
        'Tata irisan pisang ambon di atasnya, nikmati selagi hangat perlahan.',
      ],
    ),
    MenuIdea(
      id: 'menu_t1_sup_ayam',
      title: 'Sup Bening Ayam Kampung & Brokoli Jahe',
      subtitle: 'Kuah bening hangat mudah dicerna saat mual, tinggi asam folat.',
      image: 'assets/images/food_soup.jpg',
      kcal: 380,
      protein: 25,
      minutes: 25,
      tags: ['Makan Siang', 'Asam Folat', 'Protein Bersih', 'TM 1'],
      mealType: MealType.lunch,
      grams: 260,
      fatG: 10,
      carbG: 46,
      ironMg: 3.4,
      zincMg: 2.6,
      benefitNote:
          'Brokoli kaya asam folat alami untuk menutup tabung saraf janin (cegah spina bifida).',
      ingredients: [
        '75 g dada ayam kampung rebus suwir',
        '40 g kuntum brokoli hijau',
        '30 g wortel potong kancing',
        '2 ruas jahe memar',
        '1 batang daun bawang & seledri',
        '500 ml kaldu ayam bening',
      ],
      steps: [
        'Didihkan kaldu ayam bening bersama jahe memar untuk aroma segar.',
        'Masukkan wortel dan brokoli, rebus sebentar agar tetap renyah bernutrisi.',
        'Masukkan suwiran ayam kampung, taburkan daun seledri segar.',
        'Sajikan hangat dalam porsi kecil namun habis tuntas.',
      ],
    ),
    MenuIdea(
      id: 'menu_t1_bubur_kacang_hijau',
      title: 'Bubur Kacang Hijau Kuah Jahe Gula Aren',
      subtitle: 'Superfood asam folat alami dan zat besi untuk sel darah merah.',
      image: 'assets/images/food_rice.jpg',
      kcal: 320,
      protein: 15,
      minutes: 30,
      tags: ['Selingan Sehat', 'Tinggi Folat', 'Cegah Anemia', 'TM 1'],
      mealType: MealType.snack,
      grams: 200,
      fatG: 5,
      carbG: 54,
      ironMg: 3.9,
      zincMg: 2.0,
      benefitNote:
          'Kacang hijau kaya asam folat dan zat besi esensial bagi pembelahan sel embrio.',
      ingredients: [
        '60 g kacang hijau rendam 2 jam',
        '2 ruas jahe memar',
        '1 lembar daun pandan wangi',
        '100 ml santan encer hangat',
        '1 sdm gula aren cair',
      ],
      steps: [
        'Rebus kacang hijau bersama daun pandan dan jahe hingga mekar empuk.',
        'Tuangkan santan encer dan gula aren, aduk perlahan dengan api kecil.',
        'Sajikan hangat sebagai selingan bergizi antara makan siang dan malam.',
      ],
    ),
    MenuIdea(
      id: 'menu_t1_tim_telur',
      title: 'Nasi Tim Telur Rebus & Tumis Tahu Jamur',
      subtitle: 'Kaya kolin untuk pembentukan otak awal janin, tekstur lembut.',
      image: 'assets/images/food_egg.jpg',
      kcal: 410,
      protein: 21,
      minutes: 20,
      tags: ['Makan Malam', 'Kolin Otak', 'Tekstur Lembut', 'TM 1'],
      mealType: MealType.dinner,
      grams: 250,
      fatG: 13,
      carbG: 52,
      ironMg: 3.6,
      zincMg: 2.2,
      benefitNote:
          'Kolin dari kuning telur merupakan nutrisi kunci perkembangan kognitif awal janin.',
      ingredients: [
        '100 g nasi putih tim lembut',
        '1 butir telur ayam rebus matang',
        '40 g tahu putih potong dadu',
        '20 g jamur tiram suwir',
        '1 siung bawang putih & kecap manis',
        '1 sdt minyak wijen',
      ],
      steps: [
        'Tumis bawang putih dan jamur tiram hingga layu harum.',
        'Masukkan tahu putih dan beri sedikit kecap manis serta minyak wijen.',
        'Sajikan berdampingan dengan nasi tim hangat dan telur rebus matang.',
      ],
    ),
  ];

  // -------------------------------------------------------------
  // MENUS TRIMESTER 2: Tambahan +300 kkal, Tulang & Organ, Kalsium & Besi
  // -------------------------------------------------------------
  static const _menusT2 = [
    MenuIdea(
      id: 'menu_t2_opor_telur',
      title: 'Opor Telur Ayam & Tempe Bacem Kuah Gurih',
      subtitle: 'Tambahan +300 kkal & kalsium tinggi untuk pembentukan rangka janin.',
      image: 'assets/images/food_egg.jpg',
      kcal: 440,
      protein: 25,
      minutes: 25,
      tags: ['Sarapan', '+300 kkal', 'Tinggi Kalsium', 'TM 2'],
      mealType: MealType.breakfast,
      grams: 260,
      fatG: 17,
      carbG: 46,
      ironMg: 4.4,
      zincMg: 2.5,
      benefitNote:
          'Kalsium dari tempe dan telur mendukung kepadatan tulang ibu dan kerangka janin.',
      ingredients: [
        '100 g nasi putih hangat',
        '1 butir telur ayam rebus',
        '60 g tempe kedelai potong',
        '100 ml santan sedang segar',
        'Bumbu opor kuning, daun salam, serai',
      ],
      steps: [
        'Tumis bumbu opor kuning bersama serai dan daun salam hingga wangi.',
        'Tuangkan santan sedang, masukkan tempe dan telur rebus.',
        'Masak dengan api sedang hingga kuah meresap gurih ke dalam lauk.',
      ],
    ),
    MenuIdea(
      id: 'menu_t2_nasi_tim_ikan',
      title: 'Nasi Tim Ikan Kembung, Bayam Merah & Tahu',
      subtitle:
          'Tinggi zat besi & kalsium alami, setara gizi salmon untuk organ janin.',
      image: 'assets/images/food_rice.jpg',
      kcal: 470,
      protein: 29,
      minutes: 25,
      tags: ['Makan Siang', 'Zat Besi Tinggi', 'Omega-3', 'TM 2'],
      mealType: MealType.lunch,
      grams: 270,
      fatG: 15,
      carbG: 55,
      ironMg: 5.9,
      zincMg: 2.9,
      benefitNote:
          'Ikan kembung kaya Omega-3 dan zat besi bayam merah melipatgandakan sel darah merah.',
      ingredients: [
        '100 g nasi pulen tim',
        '70 g ikan kembung kukus suwir bersih',
        '40 g daun bayam merah rebus',
        '30 g tahu putih kukus',
        '1 sdt minyak kelapa murni',
      ],
      steps: [
        'Kukus ikan kembung bersama irisan kunyit dan serai hingga matang empuk.',
        'Rebus bayam merah sebentar saja agar warna dan zat besinya terjaga.',
        'Sajikan nasi tim bersama suwiran ikan kembung, tahu, dan bayam merah hangat.',
      ],
    ),
    MenuIdea(
      id: 'menu_t2_setup_buah',
      title: 'Setup Pepaya Manis, Jeruk & Biji Labu',
      subtitle: 'Vitamin C tinggi pelipatganda serap zat besi TTD & cegah sembelit.',
      image: 'assets/images/food_soup.jpg',
      kcal: 230,
      protein: 7,
      minutes: 10,
      tags: ['Selingan', 'Vitamin C', 'Serat Sehat', 'TM 2'],
      mealType: MealType.snack,
      grams: 180,
      fatG: 4,
      carbG: 42,
      ironMg: 2.3,
      zincMg: 1.7,
      benefitNote:
          'Vitamin C alami dari jeruk & pepaya memaksimalkan penyerapan tablet tambah darah (TTD).',
      ingredients: [
        '80 g pepaya matang potong dadu',
        '1 buah jeruk manis kupas juring',
        '1 sdm biji labu kupas panggang',
        'Sedikit air perasan lemon',
      ],
      steps: [
        'Campur potongan pepaya matang dan juring jeruk manis dalam mangkuk.',
        'Taburkan biji labu panggang renyah kaya zink dan magnesium.',
        'Kucuri sedikit perasan lemon, nikmati segar dingin atau suhu ruang.',
      ],
    ),
    MenuIdea(
      id: 'menu_t2_semur_hati_ayam',
      title: 'Semur Hati Ayam, Kentang & Buncis Manis',
      subtitle: 'Superfood pencegah anemia kehamilan (HEME-IRON tertinggi).',
      image: 'assets/images/food_soup.jpg',
      kcal: 460,
      protein: 28,
      minutes: 25,
      tags: ['Makan Malam', 'Superfood Besi', 'Bebas Anemia', 'TM 2'],
      mealType: MealType.dinner,
      grams: 260,
      fatG: 14,
      carbG: 54,
      ironMg: 7.4,
      zincMg: 3.6,
      benefitNote:
          'Hati ayam merupakan sumber zat besi heme terbaik untuk menaikkan kadar hemoglobin (Hb).',
      ingredients: [
        '70 g hati ayam segar rebus matang',
        '50 g kentang potong dadu rebus',
        '30 g buncis muda potong',
        'Bawang merah, bawang putih, pala bubuk',
        '2 sdm kecap manis beryodium',
      ],
      steps: [
        'Tumis bawang merah, bawang putih, dan bubuk pala hingga harum.',
        'Masukkan hati ayam rebus dan kentang, tuang air dan kecap manis.',
        'Masak hingga kuah semur meresap gurih, masukkan buncis sesaat sebelum diangkat.',
      ],
    ),
  ];

  // -------------------------------------------------------------
  // MENUS TRIMESTER 3: Protein 85 g/hari, DHA Otak Janin, Persiapan Lahir & ASI
  // -------------------------------------------------------------
  static const _menusT3 = [
    MenuIdea(
      id: 'menu_t3_nasi_uduk_telur',
      title: 'Nasi Uduk Gurih Telur Dadar Bayam & Tempe Orek',
      subtitle:
          'Pasokan energi persalinan & protein tinggi penopang kontraksi rahim.',
      image: 'assets/images/food_egg.jpg',
      kcal: 480,
      protein: 26,
      minutes: 20,
      tags: ['Sarapan', 'Energi Lahir', 'Protein Tinggi', 'TM 3'],
      mealType: MealType.breakfast,
      grams: 270,
      fatG: 18,
      carbG: 54,
      ironMg: 4.8,
      zincMg: 2.7,
      benefitNote:
          'Menyediakan cadangan glikogen dan stamina otot untuk proses persalinan.',
      ingredients: [
        '100 g nasi uduk santan gurih',
        '1 butir telur ayam dadar campur bayam',
        '50 g tempe orek manis kering',
        'Timun segar iris tipis',
      ],
      steps: [
        'Kocok telur bersama cincangan halus daun bayam, dadar hingga matang sempurna.',
        'Sajikan bersama nasi uduk harum dan tempe orek manis kaya kalsium.',
        'Lengkapi dengan irisan timun segar penghidrasi alami.',
      ],
    ),
    MenuIdea(
      id: 'menu_t3_ikan_bakar_kunyit',
      title: 'Ikan Kembung/Tongkol Bakar & Lalap Labu Siam',
      subtitle:
          'Kaya asam lemak DHA & Omega-3 untuk percepatan retina & otak janin.',
      image: 'assets/images/food_rice.jpg',
      kcal: 470,
      protein: 32,
      minutes: 25,
      tags: ['Makan Siang', 'DHA & Omega-3', 'Retina & Otak', 'TM 3'],
      mealType: MealType.lunch,
      grams: 270,
      fatG: 15,
      carbG: 50,
      ironMg: 5.1,
      zincMg: 3.3,
      benefitNote:
          'DHA menumpuk pesat di jaringan otak janin pada trimester ke-3 kehamilan.',
      ingredients: [
        '100 g nasi putih pulen',
        '85 g ikan kembung/tongkol segar bakar bumbu kuning',
        '50 g labu siam kukus lembut',
        'Sambal tomat matang non-pedas',
      ],
      steps: [
        'Lumuri ikan laut dengan perasan jeruk nipis, kunyit, dan bawang putih halus.',
        'Panggang ikan di wajan teflon hingga harum matang keemasan.',
        'Sajikan bersama lalapan labu siam kukus yang kaya air dan serat lembut.',
      ],
    ),
    MenuIdea(
      id: 'menu_t3_smoothie_kurma',
      title: 'Smoothies Alpukat Susu Kurma & Biji Chia',
      subtitle:
          'Lemak tak jenuh pembentuk ASI dini & kurma pelemas jalan lahir alami.',
      image: 'assets/images/food_soup.jpg',
      kcal: 290,
      protein: 9,
      minutes: 10,
      tags: ['Selingan', 'Persiapan ASI', 'Oksitosin Alami', 'TM 3'],
      mealType: MealType.snack,
      grams: 220,
      fatG: 13,
      carbG: 36,
      ironMg: 2.4,
      zincMg: 1.9,
      benefitNote:
          'Kurma terbukti klinis meningkatkan elastisitas serviks dan asam lemak alpukat memperkaya kolostrum.',
      ingredients: [
        '80 g daging alpukat mentega matang',
        '3 butir kurma sukari buang biji',
        '150 ml susu pasteurisasi / UHT',
        '1 sdt biji chia',
      ],
      steps: [
        'Blender daging alpukat, kurma, dan susu hingga tekstur kental lembut.',
        'Tuangkan ke gelas, taburkan biji chia di atasnya.',
        'Minum dingin segar di sore hari untuk menyegarkan stamina Bunda.',
      ],
    ),
    MenuIdea(
      id: 'menu_t3_bola_daging',
      title: 'Sup Bola Daging Sapi, Brokoli & Telur Puyuh',
      subtitle: 'Protein murni (32 g) & zat besi cadangan darah persalinan aman.',
      image: 'assets/images/food_soup.jpg',
      kcal: 490,
      protein: 34,
      minutes: 30,
      tags: ['Makan Malam', 'Cegah Perdarahan', 'Protein Murni', 'TM 3'],
      mealType: MealType.dinner,
      grams: 280,
      fatG: 16,
      carbG: 50,
      ironMg: 6.8,
      zincMg: 4.2,
      benefitNote:
          'Kombinasi zat besi daging sapi dan telur puyuh membentengi Ibu dari perdarahan saat bersalin.',
      ingredients: [
        '100 g nasi putih',
        '75 g daging sapi giling bulat',
        '3 butir telur puyuh rebus matang',
        '40 g kuntum brokoli kukus',
        '500 ml kaldu gurih berempah pala & lada halus',
      ],
      steps: [
        'Bentuk daging giling segar menjadi bola-bola lembut.',
        'Rebus dalam kaldu mendidih bersama bumbu pala hingga bola mengapung matang.',
        'Masukkan brokoli dan telur puyuh rebus, sajikan hangat berkuah lezat.',
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

  List<MenuIdea> get _currentMenus {
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

  void _logMealToDiary(MenuIdea menu) {
    final state = ref.read(appControllerProvider);
    final pregnancy = state.activePregnancy;
    final child = state.activeChild;
    final subjectId = widget.pregnancyMode
        ? (pregnancy?.id ?? 'preg_active')
        : (child?.id ?? 'child_active');

    ref
        .read(appControllerProvider.notifier)
        .addFoodLog(
          subjectId: subjectId,
          meal: menu.mealType,
          items: [menu.toFoodLogItem()],
          date: DateTime.now(),
          note: '${menu.title} (${menu.benefitNote ?? 'Rekomendasi NURI'})',
        );

    HapticFeedback.mediumImpact();
    showNuriSnack(
      context,
      'Menu "${menu.title}" dicatat ke ${menu.mealType.label} hari ini! (+${menu.kcal} kkal)',
    );
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
                    RecommendationHeroBanner(
                      pregnancyMode: widget.pregnancyMode,
                      trimester: _selectedTrimester,
                    ),
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
                      RecommendationTrimesterGuideCard(
                        trimester: _selectedTrimester,
                      ),
                    ],
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: widget.pregnancyMode
                          ? 'Menu Rekomendasi Trimester $_selectedTrimester'
                          : 'Menu hari ini',
                      subtitle: 'Pilih dan catat menu ke buku makan harian.',
                    ),
                    const SizedBox(height: 10),
                    ...menus.map(
                      (menu) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RecommendationMenuCard(
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
                          onLogMeal: () => _logMealToDiary(menu),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    NuriButton(
                      label: 'Simpan rencana makan mingguan',
                      icon: Icons.check_rounded,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 22),
                    SectionHeader(
                      title: 'Standar porsi gizi',
                      subtitle: widget.pregnancyMode
                          ? 'Kebutuhan harian Trimester $_selectedTrimester'
                          : 'Panduan umum usia 1–3 tahun',
                    ),
                    const SizedBox(height: 10),
                    RecommendationPortionGuide(
                      pregnancyMode: widget.pregnancyMode,
                      trimester: _selectedTrimester,
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(
                      title: 'Piring 4 bintang',
                      subtitle: 'Empat kelompok makanan dalam satu piring.',
                    ),
                    const SizedBox(height: 10),
                    const RecommendationFourStarGrid(),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Cara menyusun'),
                    const SizedBox(height: 10),
                    const RecommendationStepsCard(),
                    const SizedBox(height: 12),
                    InfoBanner(
                      title: widget.pregnancyMode
                          ? 'Perhatikan selama hamil'
                          : 'Perhatikan saat memberi makan',
                      body: widget.pregnancyMode
                          ? 'Pastikan daging, telur, dan ikan dimasak matang sempurna (100%), hindari susu mentah non-pasteurisasi, batasi kafein (< 200 mg/hari), dan minum Tablet Tambah Darah (TTD) rutin.'
                          : 'Hindari madu untuk anak di bawah 1 tahun, batasi gula/garam, dan sesuaikan tekstur dengan usia.',
                      icon: Icons.health_and_safety_outlined,
                      background: AppColors.peachSoft,
                      foreground: AppColors.coral,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sumber: ${AkgReference.sourceLabel} & TKPI 2017 Kemenkes RI.',
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

  void _showRecipe(MenuIdea menu) {
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
            Row(
              children: [
                Pill(
                  label: menu.mealType.label,
                  background: AppColors.primarySoft,
                  foreground: AppColors.primaryDark,
                  fontSize: 11,
                  bold: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    menu.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              menu.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            if (menu.benefitNote != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryFixedDim.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        menu.benefitNote!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                RecommendationRecipeMetric(
                  icon: Icons.local_fire_department_rounded,
                  value: '${menu.kcal} kkal',
                ),
                RecommendationRecipeMetric(
                  icon: Icons.fitness_center_rounded,
                  value: '${menu.protein} g protein',
                ),
                RecommendationRecipeMetric(
                  icon: Icons.bloodtype_rounded,
                  value: '${menu.ironMg.toStringAsFixed(1)} mg Fe',
                ),
                RecommendationRecipeMetric(
                  icon: Icons.schedule_rounded,
                  value: '${menu.minutes} menit',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bahan-bahan',
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
            const SizedBox(height: 16),
            NuriButton(
              label: 'Catat Menu ini ke Buku Makan Hari Ini',
              icon: Icons.add_circle_outline_rounded,
              onPressed: () {
                Navigator.of(context).pop();
                _logMealToDiary(menu);
              },
            ),
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
