import '../core/domain_error.dart';
import '../core/result.dart';

final class Photo {
  const Photo._({
    required this.url,
    required this.contentType,
    required this.sizeBytes,
  });

  final String url;
  final String contentType;
  final int sizeBytes;

  static const int maxSizeBytes = 5 * 1024 * 1024;
  static const Set<String> allowedContentTypes = {'image/jpeg', 'image/png'};

  static Result<Photo, DomainError> create({
    required String url,
    required String contentType,
    required int sizeBytes,
  }) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      return const Failure(InvalidPhoto('url boş olamaz'));
    }
    if (!allowedContentTypes.contains(contentType)) {
      return const Failure(
        InvalidPhoto('contentType yalnızca image/jpeg veya image/png olabilir'),
      );
    }
    if (sizeBytes <= 0) {
      return const Failure(InvalidPhoto('dosya boyutu 0’dan büyük olmalı'));
    }
    if (sizeBytes > maxSizeBytes) {
      return const Failure(InvalidPhoto('dosya boyutu 5 MB’ı geçemez'));
    }
    return Success(
      Photo._(url: trimmedUrl, contentType: contentType, sizeBytes: sizeBytes),
    );
  }
}
