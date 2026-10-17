import 'package:campus_domain/campus_domain.dart';

import 'app_error.dart';

AppError mapDomainError(DomainError error) => switch (error) {
  InvalidRole() => const ForbiddenError(),
  InvalidTransition() => const InvalidTransitionError(),
  MissingResolutionPhoto() => const MissingResolutionPhotoError(),
  InvalidPhoto(:final reason) => ValidationError('photo', reason),
  InvalidLocation(:final reason) => ValidationError('location', reason),
  InvalidDescription(:final reason) => ValidationError('description', reason),
  InvalidId(:final reason) => ValidationError('id', reason),
};
