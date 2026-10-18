/// Domain katmanındaki iş kuralı ihlalleri. Akış kontrolü için istisna
/// fırlatılmaz, bu değerler [Result] içinde döner.
sealed class DomainError {
  const DomainError();
}

final class InvalidRole extends DomainError {
  const InvalidRole();
}

final class InvalidTransition extends DomainError {
  const InvalidTransition();
}

final class MissingResolutionPhoto extends DomainError {
  const MissingResolutionPhoto();
}

final class InvalidPhoto extends DomainError {
  const InvalidPhoto(this.reason);

  final String reason;
}

final class InvalidLocation extends DomainError {
  const InvalidLocation(this.reason);

  final String reason;
}

final class InvalidDescription extends DomainError {
  const InvalidDescription(this.reason);

  final String reason;
}

final class InvalidId extends DomainError {
  const InvalidId(this.reason);

  final String reason;
}
