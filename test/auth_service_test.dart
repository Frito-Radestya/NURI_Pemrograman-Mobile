import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/models/user_role.dart';
import 'package:stunting_care/services/auth_service.dart';

void main() {
  final auth = AuthService();

  setUp(auth.logout);

  test('Login demo diterima hanya dengan kredensial yang benar', () async {
    final ok = await auth.login(
      identifier: 'divaputri@gmail.com',
      password: AuthService.demoPassword,
      role: UserRole.ibuBalita,
    );
    expect(ok, isTrue);
    expect(auth.currentUser?.name, 'Diva Putri Adilla');

    final failed = await auth.login(
      identifier: 'divaputri@gmail.com',
      password: 'salah-total',
      role: UserRole.ibuBalita,
    );
    expect(failed, isFalse);
  });

  test('OTP hanya menerima kode demo 1234', () async {
    expect(await auth.verifyOtp('1234'), isTrue);
    expect(await auth.verifyOtp('9999'), isFalse);
  });

  test('Akun terdaftar bisa login dan tidak bisa didaftarkan ganda', () async {
    final registered = await auth.register(
      name: 'Uji Coba',
      emailOrPhone: 'uji@example.com',
      password: 'Rahasia123',
      role: UserRole.ibuBalita,
    );
    expect(registered, isTrue);

    auth.logout();
    final duplicate = await auth.register(
      name: 'Uji Lagi',
      emailOrPhone: 'uji@example.com',
      password: 'Rahasia123',
      role: UserRole.ibuBalita,
    );
    expect(duplicate, isFalse);

    final ok = await auth.login(
      identifier: 'uji@example.com',
      password: 'Rahasia123',
      role: UserRole.ibuBalita,
    );
    expect(ok, isTrue);
  });
}
