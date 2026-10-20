import 'package:campus_server/src/service/password_hasher.dart';
import 'package:test/test.dart';

import '../support/test_values.dart';

void main() {
  // Test hızlı olsun diye düşük maliyet; üretimde 12.
  final hasher = PasswordHasher(cost: 4);

  test('hasher_defaultCost_is12', () {
    expect(PasswordHasher.defaultCost, 12);
  });

  test('hasher_correctPassword_verifies', () {
    final hash = hasher.hash(testPassword);
    expect(hash, isNot(testPassword));
    expect(hasher.verify(testPassword, hash), isTrue);
  });

  test('hasher_wrongPassword_fails', () {
    expect(hasher.verify('yanlis', hasher.hash(testPassword)), isFalse);
  });

  test('hasher_dummy_alwaysFalse', () {
    expect(hasher.verifyAgainstDummy(testPassword), isFalse);
  });
}
