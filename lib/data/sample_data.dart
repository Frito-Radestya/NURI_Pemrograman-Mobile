import '../models/recipe.dart';

class SampleData {
  static const userName = 'Diva Putri Adilla';
  static const userUsername = 'Divaputriadilla';

  static const avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop';

  static const nurseIllustration =
      'https://cdn-icons-png.flaticon.com/512/3774/3774299.png';

  static const doctorPhoto =
      'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&h=500&fit=crop';

  static const newsImage =
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=600&h=400&fit=crop';

  static final List<Recipe> recipes = [
    Recipe(
      id: '1',
      title: 'Bubur Ikan Dori',
      time: '15 menit',
      ingredientsPreview: '1 ikan | 5 wortel | 3 bawang bombay',
      imageUrl: 'https://picsum.photos/seed/nuri-bubur-ikan/800/500',
      category: 'Sarapan',
      ingredients: const [
        '1 ruas ikan dori',
        '3 sendok makan beras',
        '3 bawang bombay',
        'Jahe secukupnya',
        'Seledri secukupnya',
      ],
      steps: const [
        RecipeStep(
          instruction: 'Rebus beras dengan 200 ml air.',
          imageUrl: 'https://picsum.photos/seed/nuri-langkah-1/400/250',
        ),
        RecipeStep(instruction: 'Aduk sampai tekstur nasi agak lembek.'),
        RecipeStep(
          instruction: 'Masukkan wortel, ikan dori, dan bawang bombay yang sudah diiris.',
        ),
      ],
    ),
    Recipe(
      id: '2',
      title: 'Nasi Tim Ayam',
      time: '35 menit',
      ingredientsPreview: 'Ayam | beras | wortel | tomat',
      imageUrl: 'https://picsum.photos/seed/nuri-nasi-tim/800/500',
      category: 'Makan Siang',
      ingredients: const [
        '1 potong ayam',
        '3 sendok makan beras',
        '1 wortel',
        '1 tomat',
      ],
      steps: const [
        RecipeStep(
          instruction: 'Masak ayam bersama beras dan sayur hingga matang.',
        ),
        RecipeStep(instruction: 'Aduk dan sajikan dalam porsi kecil.'),
      ],
    ),
    Recipe(
      id: '3',
      title: 'Bubur Hati Ayam',
      time: '45 menit',
      ingredientsPreview: 'Hati ayam | beras | bayam',
      imageUrl: 'https://picsum.photos/seed/nuri-bubur-hati/800/500',
      category: 'Makan Siang',
      ingredients: const [
        '50 gram hati ayam',
        '3 sendok makan beras',
        'Wortel secukupnya',
        'Bayam secukupnya',
      ],
      steps: const [
        RecipeStep(instruction: 'Rebus hati ayam hingga matang.'),
        RecipeStep(instruction: 'Haluskan bersama beras dan sayur.'),
      ],
    ),
    Recipe(
      id: '4',
      title: 'Sup Iga Sapi',
      time: '40 menit',
      ingredientsPreview: 'Iga sapi | kentang | wortel',
      imageUrl: 'https://picsum.photos/seed/nuri-sup-iga/800/500',
      category: 'Makan Malam',
      ingredients: const [
        '100 gram iga sapi',
        '1 kentang',
        '1 wortel',
        'Garam secukupnya',
      ],
      steps: const [
        RecipeStep(instruction: 'Rebus iga sapi hingga empuk.'),
        RecipeStep(
          instruction: 'Tambahkan kentang dan wortel serta garam secukupnya.',
        ),
      ],
    ),
    Recipe(
      id: '5',
      title: 'Bubur Ubi Ungu',
      time: '25 menit',
      ingredientsPreview: 'Ubi ungu | susu | buah',
      imageUrl: 'https://picsum.photos/seed/nuri-ubi-ungu/800/500',
      category: 'Camilan',
      bookmarked: true,
      ingredients: const [
        '1 buah ubi ungu',
        '50 ml susu formula',
        'Buah yang dihaluskan',
      ],
      steps: const [
        RecipeStep(instruction: 'Kukus ubi ungu hingga lembut.'),
        RecipeStep(instruction: 'Haluskan dan campur dengan susu.'),
      ],
    ),
    Recipe(
      id: '6',
      title: 'Puree Alpukat & Pisang',
      time: '10 menit',
      ingredientsPreview: 'Alpukat | pisang | ASI/susu',
      imageUrl: 'https://picsum.photos/seed/nuri-alpukat-pisang/800/500',
      category: 'Camilan',
      ingredients: const [
        '1/2 buah alpukat matang',
        '1/2 buah pisang manis',
        '30 ml ASI atau susu formula',
      ],
      steps: const [
        RecipeStep(instruction: 'Kerok daging buah alpukat dan pisang.'),
        RecipeStep(instruction: 'Haluskan dengan sendok atau blender.'),
        RecipeStep(
          instruction: 'Tambahkan ASI atau susu formula, aduk rata dan sajikan.',
        ),
      ],
    ),
    Recipe(
      id: '7',
      title: 'Sup Brokoli Daging Sapi',
      time: '30 menit',
      ingredientsPreview: 'Daging sapi | brokoli | wortel | bawang',
      imageUrl: 'https://picsum.photos/seed/nuri-sup-brokoli/800/500',
      category: 'Makan Malam',
      ingredients: const [
        '50 gram daging sapi cincang',
        '3 kuntum brokoli',
        '1/2 batang wortel',
        '1 siung bawang putih',
      ],
      steps: const [
        RecipeStep(instruction: 'Tumis bawang putih halus hingga harum.'),
        RecipeStep(
          instruction: 'Masukkan daging sapi cincang, masak hingga berubah warna.',
        ),
        RecipeStep(
          instruction: 'Tambahkan air, wortel, dan brokoli. Rebus hingga empuk.',
        ),
      ],
    ),
    Recipe(
      id: '8',
      title: 'Tim Telur Tahu Lembut',
      time: '20 menit',
      ingredientsPreview: 'Telur ayam | tahu putih | daun bawang',
      imageUrl: 'https://picsum.photos/seed/nuri-tim-telur/800/500',
      category: 'Sarapan',
      ingredients: const [
        '1 butir telur ayam',
        '50 gram tahu putih, hancurkan',
        '1 batang daun bawang cincang',
        '100 ml kaldu ayam',
      ],
      steps: const [
        RecipeStep(
          instruction: 'Kocok telur bersama kaldu ayam dan tahu yang sudah dihancurkan.',
        ),
        RecipeStep(
          instruction: 'Tuang ke dalam wadah tahan panas, taburi daun bawang.',
        ),
        RecipeStep(
          instruction: 'Kukus selama 15 menit hingga matang dan lembut.',
        ),
      ],
    ),
    Recipe(
      id: '9',
      title: 'Puree Labu Kuning & Salmon',
      time: '25 menit',
      ingredientsPreview: 'Labu kuning | salmon | olive oil',
      imageUrl: 'https://picsum.photos/seed/nuri-labu-salmon/800/500',
      category: 'Makan Siang',
      ingredients: const [
        '100 gram labu kuning',
        '40 gram fillet salmon',
        '1 sdt minyak zaitun',
      ],
      steps: const [
        RecipeStep(
          instruction: 'Kukus labu kuning dan fillet salmon hingga matang sempurna.',
        ),
        RecipeStep(
          instruction: 'Saring atau blender labu dan salmon bersama sedikit air kukusan.',
        ),
        RecipeStep(instruction: 'Tambahkan minyak zaitun sebelum disajikan.'),
      ],
    ),
    Recipe(
      id: '10',
      title: 'Smoothies Buah & Oatmeal',
      time: '10 menit',
      ingredientsPreview: 'Oatmeal | buah naga | susu',
      imageUrl: 'https://picsum.photos/seed/nuri-oatmeal-buah/800/500',
      category: 'Camilan',
      ingredients: const [
        '2 sendok makan oatmeal instan',
        '50 gram buah naga merah',
        '100 ml susu UHT / susu anak',
      ],
      steps: const [
        RecipeStep(
          instruction: 'Seduh oatmeal dengan air hangat hingga lembut.',
        ),
        RecipeStep(
          instruction: 'Blender oatmeal bersama dengan buah naga dan susu.',
        ),
        RecipeStep(instruction: 'Sajikan segar untuk camilan sehat kaya serat.'),
      ],
    ),
  ];
}
