import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/data/food_database.dart';
import 'package:stunting_care/services/food_diary_service.dart';

void main() {
  final service = FoodDiaryService();
  final date = DateTime(2026, 9, 25);

  setUp(() => service.clear());

  test('Food diary menyimpan relasi ID dan mendukung update', () {
    final food = FoodDatabase.findById('ayam_goreng')!;
    final entry = food.toEntry(
      entryId: service.generateId(),
      userId: 'usr_test',
      dateKey: FoodDiaryService.dateKey(date),
      session: 'siang',
      gram: 80,
    );

    service.addEntry(date, entry);

    expect(entry.foodItemId, 'ayam_goreng');
    expect(entry.categoryId, 'cat_protein_hewani');
    expect(service.getEntries(userId: 'usr_test', date: date), hasLength(1));

    final updated = entry.copyWith(portionGram: 100, session: 'malam');
    service.updateEntry(date, updated);

    final saved = service.getEntries(userId: 'usr_test', date: date).single;
    expect(saved.portionGram, 100);
    expect(saved.session, 'malam');
  });

  test('Data food diary terisolasi antar pengguna', () {
    final food = FoodDatabase.findById('pisang')!;
    service.addEntry(
      date,
      food.toEntry(
        entryId: 'entry_ibu',
        userId: 'usr_ibu',
        dateKey: FoodDiaryService.dateKey(date),
        session: 'snack',
        gram: 100,
      ),
    );

    expect(
      service.getEntries(userId: 'usr_ibu', date: date),
      hasLength(1),
    );
    expect(
      service.getEntries(userId: 'usr_kader', date: date),
      isEmpty,
    );
  });

  test('Delete menghapus entry milik user yang benar', () {
    final food = FoodDatabase.findById('bayam')!;
    service.addEntry(
      date,
      food.toEntry(
        entryId: 'entry_hapus',
        userId: 'usr_ibu',
        dateKey: FoodDiaryService.dateKey(date),
        session: 'pagi',
        gram: 100,
      ),
    );

    service.removeEntry(userId: 'usr_ibu', date: date, entryId: 'entry_hapus');

    expect(service.getEntries(userId: 'usr_ibu', date: date), isEmpty);
  });
}
