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
  ];
}
