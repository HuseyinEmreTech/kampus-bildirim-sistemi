/// Uygulama katmanı hataları. Her yeni hata için sunucu eşlemesi de
/// [AppError] alt sınıfı olarak eklenir; böylece `switch` ifadesinde unutulmaz.
sealed class AppError {
  const AppError();
}

final class ValidationError extends AppError {
  const ValidationError(this.field, this.message);

  final String field;
  final String message;
}

final class UnauthorizedError extends AppError {
  const UnauthorizedError();
}

final class ForbiddenError extends AppError {
  const ForbiddenError();
}

final class NotFoundError extends AppError {
  const NotFoundError();
}

final class ConflictError extends AppError {
  const ConflictError(this.reason);

  final String reason;
}

final class InvalidTransitionError extends AppError {
  const InvalidTransitionError();
}

final class MissingResolutionPhotoError extends AppError {
  const MissingResolutionPhotoError();
}

final class UnknownError extends AppError {
  const UnknownError(this.message);

  final String message;
}
