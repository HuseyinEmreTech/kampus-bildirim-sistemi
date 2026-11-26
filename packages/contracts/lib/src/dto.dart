class AuthResponseDto {
  static AuthResponseDto? fromJson(Map<String, Object?> json) => null;

  Map<String, Object?> toJson() => {};
}

class ReportListItemDto {
  static ReportListItemDto? fromJson(Map<String, Object?> json) => null;

  Map<String, Object?> toJson() => {};
}

class ReportDetailDto {
  static ReportDetailDto? fromJson(Map<String, Object?> json) => null;

  Map<String, Object?> toJson() => {};
}

class StatusChangeDto {
  static StatusChangeDto? fromJson(Map<String, Object?> json) => null;

  Map<String, Object?> toJson() => {};
}

class PageDto<T> {
  static PageDto<T>? fromJson<T>(
    Map<String, Object?> json, {
    required T? Function(Map<String, Object?>) itemFromJson,
  }) => null;

  Map<String, Object?> toJson({
    required Object? Function(T) itemToJson,
  }) => {};
}

class NotificationDto {
  static NotificationDto? fromJson(Map<String, Object?> json) => null;

  Map<String, Object?> toJson() => {};
}

class BuildingDto {
  static BuildingDto? fromJson(Map<String, Object?> json) => null;

  Map<String, Object?> toJson() => {};
}

class ApiErrorDto {
  static ApiErrorDto? fromJson(Map<String, Object?> json) => null;

  Map<String, Object?> toJson() => {};
}
