import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/models/child_profile.dart';
import 'package:stunting_care/services/child_service.dart';

void main() {
  final service = ChildService();

  setUp(() => service.resetDemoData());

  test('Data anak Kader menyediakan minimal 20 record simulasi', () {
    final children = service.getChildren('usr_03');
    expect(children.length, greaterThanOrEqualTo(20));
    expect(children.every((child) => child.ownerUserId == 'usr_03'), isTrue);
  });

  test('CRUD data anak create, read, update, dan delete', () {
    final child = ChildProfile(
      id: service.generateId('usr_ibu'),
      ownerUserId: 'usr_ibu',
      name: 'Anika',
      birthDate: DateTime(2024, 1, 1),
      gender: 'P',
      weightKg: 8.4,
      heightCm: 70.2,
      motherName: 'Ibu Test',
      lastCheckDate: DateTime(2026, 9, 25),
      status: 'Normal',
    );

    service.addChild(child);
    expect(service.findById(child.id)?.name, 'Anika');

    service.updateChild(child.copyWith(weightKg: 9.1));
    expect(service.findById(child.id)?.weightKg, 9.1);

    service.deleteChild(child.id);
    expect(service.findById(child.id), isNull);
  });

  test('Data anak ibu bersifat terpisah dari data kader', () {
    expect(service.getChildren('usr_01'), hasLength(1));
    expect(service.getChildren('usr_03').length, greaterThanOrEqualTo(20));
  });
}
