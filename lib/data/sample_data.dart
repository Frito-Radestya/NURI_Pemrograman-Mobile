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
      time: '15 min',
      ingredientsPreview: '1 fish | 5 carrot | etc.',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&h=500&fit=crop',
      category: 'Breakfast',
      ingredients: const [
        '1 Ruas ikan dori',
        '3 Sendok makan beras',
        '3 Bawang bombay',
        'Jahe secukupnya',
        'Seledri',
      ],
      steps: const [
        RecipeStep(
          instruction: 'Rebus beras dengan 200 ml air.',
          imageUrl:
              'https://images.unsplash.com/photo-1516684733122-df022752128b?w=400&h=250&fit=crop',
        ),
        RecipeStep(
          instruction: 'Aduk sampai tekstur nasi agak lembek.',
        ),
        RecipeStep(
          instruction:
              'Masukkan wortel, ikan dori, dan bawang bombay yang sudah diiris kasar.',
        ),
      ],
    ),
    Recipe(
      id: '2',
      title: 'Bubur Hati Ayam',
      time: '45 min',
      ingredientsPreview: 'milk | oatmeal | lorem etc.',
      imageUrl:
          'https://images.unsplash.com/photo-1494859802830-b7c1d0a0e8a8?w=800&h=500&fit=crop',
      category: 'Breakfast',
      ingredients: const [
        '50g hati ayam',
        '3 Sendok makan beras',
        'Wortel secukupnya',
        'Bayam secukupnya',
      ],
      steps: const [
        RecipeStep(instruction: 'Rebus hati ayam hingga matang.'),
        RecipeStep(instruction: 'Haluskan bersama beras dan sayur.'),
      ],
    ),
    Recipe(
      id: '3',
      title: 'Bubur Ubi Ungu',
      time: '25 min',
      ingredientsPreview: 'milk | oatmeal | fruits etc.',
      imageUrl:
          'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=800&h=500&fit=crop',
      category: 'Breakfast',
      bookmarked: true,
      ingredients: const [
        '1 buah ubi ungu',
        '50 ml ASI / susu formula',
        'Buah secukupnya',
      ],
      steps: const [
        RecipeStep(instruction: 'Kukus ubi ungu hingga lembut.'),
        RecipeStep(instruction: 'Haluskan dan campur dengan susu.'),
      ],
    ),
  ];
}
