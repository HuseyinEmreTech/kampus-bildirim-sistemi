// Veritabanı gerektirmez; CI'da (-x db) da çalışır.
import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

void main() {
  test('fromUrl_withWrongScheme_throwsArgumentError', () {
    expect(
      () => Database.fromUrl('mysql://campus@localhost:5440/campus'),
      throwsArgumentError,
    );
  });
}
