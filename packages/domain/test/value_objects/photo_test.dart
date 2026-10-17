import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

void main() {
  test('create_validJpeg_returnsSuccess', () {
    final result = Photo.create(
      url: '/files/lamba.jpg',
      contentType: 'image/jpeg',
      sizeBytes: 812345,
    );
    expect(result, isA<Success<Photo, DomainError>>());
  });

  test('create_invalidContentType_returnsInvalidPhoto', () {
    final result = Photo.create(
      url: '/files/lamba.jpg',
      contentType: 'image/gif',
      sizeBytes: 812345,
    );
    expect(result, isA<Failure<Photo, DomainError>>());
  });

  test('create_zeroSize_returnsInvalidPhoto', () {
    final result = Photo.create(
      url: '/files/lamba.jpg',
      contentType: 'image/jpeg',
      sizeBytes: 0,
    );
    expect(result, isA<Failure<Photo, DomainError>>());
  });

  test('create_tooLarge_returnsInvalidPhoto', () {
    final result = Photo.create(
      url: '/files/lamba.jpg',
      contentType: 'image/jpeg',
      sizeBytes: 6 * 1024 * 1024,
    );
    expect(result, isA<Failure<Photo, DomainError>>());
  });
}
