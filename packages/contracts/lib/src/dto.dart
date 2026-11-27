class AuthUserDto {
  const AuthUserDto({
    required this.userId,
    required this.fullName,
    required this.role,
  });

  final String userId;
  final String fullName;
  final String role;

  static AuthUserDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'userId': final String userId,
      'fullName': final String fullName,
      'role': final String role,
    }) {
      return AuthUserDto(userId: userId, fullName: fullName, role: role);
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'role': role,
  };
}

class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUserDto user;

  static AuthResponseDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'accessToken': final String accessToken,
      'refreshToken': final String refreshToken,
      'user': final Map<String, Object?> userJson,
    }) {
      final user = AuthUserDto.fromJson(userJson);
      if (user == null) return null;
      return AuthResponseDto(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };
}

class ReportListItemDto {
  const ReportListItemDto({
    required this.reportId,
    required this.category,
    required this.description,
    required this.status,
    required this.place,
    required this.buildingName,
    required this.photoUrl,
    required this.assigneeId,
    required this.createdAt,
  });

  final String reportId;
  final String category;
  final String description;
  final String status;
  final String place;
  final String? buildingName;
  final String? photoUrl;
  final String? assigneeId;
  final DateTime createdAt;

  static ReportListItemDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'reportId': final String reportId,
      'category': final String category,
      'description': final String description,
      'status': final String status,
      'place': final String place,
      'buildingName': final String? buildingName,
      'photoUrl': final String? photoUrl,
      'assigneeId': final String? assigneeId,
      'createdAt': final String createdAtValue,
    }) {
      final createdAt = DateTime.tryParse(createdAtValue);
      if (createdAt == null) return null;
      return ReportListItemDto(
        reportId: reportId,
        category: category,
        description: description,
        status: status,
        place: place,
        buildingName: buildingName,
        photoUrl: photoUrl,
        assigneeId: assigneeId,
        createdAt: createdAt,
      );
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'reportId': reportId,
    'category': category,
    'description': description,
    'status': status,
    'place': place,
    'buildingName': buildingName,
    'photoUrl': photoUrl,
    'assigneeId': assigneeId,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

class StatusChangeDto {
  const StatusChangeDto({
    required this.status,
    required this.changedAt,
    required this.note,
  });

  final String status;
  final DateTime changedAt;
  final String? note;

  static StatusChangeDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'status': final String status,
      'changedAt': final String changedAtValue,
      'note': final String? note,
    }) {
      final changedAt = DateTime.tryParse(changedAtValue);
      if (changedAt == null) return null;
      return StatusChangeDto(status: status, changedAt: changedAt, note: note);
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'status': status,
    'changedAt': changedAt.toUtc().toIso8601String(),
    'note': note,
  };
}

class ReportDetailDto {
  const ReportDetailDto({
    required this.reportId,
    required this.category,
    required this.description,
    required this.status,
    required this.place,
    required this.buildingName,
    required this.photoUrl,
    required this.createdAt,
    required this.history,
    required this.resolutionPhotoUrl,
    required this.resolutionNote,
  });

  final String reportId;
  final String category;
  final String description;
  final String status;
  final String place;
  final String? buildingName;
  final String? photoUrl;
  final DateTime createdAt;
  final List<StatusChangeDto> history;
  final String? resolutionPhotoUrl;
  final String? resolutionNote;

  static ReportDetailDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'reportId': final String reportId,
      'category': final String category,
      'description': final String description,
      'status': final String status,
      'place': final String place,
      'buildingName': final String? buildingName,
      'photoUrl': final String? photoUrl,
      'createdAt': final String createdAtValue,
      'history': final List<Object?> historyJson,
    }) {
      final createdAt = DateTime.tryParse(createdAtValue);
      if (createdAt == null) return null;

      final history = _statusChangesFromJson(historyJson);
      if (history == null) return null;
      final resolution = _resolutionFromJson(json);
      if (resolution == null) return null;

      return ReportDetailDto(
        reportId: reportId,
        category: category,
        description: description,
        status: status,
        place: place,
        buildingName: buildingName,
        photoUrl: photoUrl,
        createdAt: createdAt,
        history: history,
        resolutionPhotoUrl: resolution.photoUrl,
        resolutionNote: resolution.note,
      );
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'reportId': reportId,
    'category': category,
    'description': description,
    'status': status,
    'place': place,
    'buildingName': buildingName,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'history': [for (final item in history) item.toJson()],
    if (resolutionPhotoUrl != null) 'resolutionPhotoUrl': resolutionPhotoUrl,
    if (resolutionPhotoUrl != null) 'resolutionNote': resolutionNote,
  };
}

List<StatusChangeDto>? _statusChangesFromJson(List<Object?> json) {
  final history = <StatusChangeDto>[];
  for (final item in json) {
    if (item is! Map<String, Object?>) return null;
    final change = StatusChangeDto.fromJson(item);
    if (change == null) return null;
    history.add(change);
  }
  return history;
}

({String? photoUrl, String? note})? _resolutionFromJson(
  Map<String, Object?> json,
) {
  final hasPhoto = json.containsKey('resolutionPhotoUrl');
  final hasNote = json.containsKey('resolutionNote');
  if (!hasPhoto && !hasNote) return (photoUrl: null, note: null);
  if (hasPhoto != hasNote) return null;

  final photo = json['resolutionPhotoUrl'];
  if (photo is! String) return null;
  final note = json['resolutionNote'];
  if (note == null) return (photoUrl: photo, note: null);
  if (note is! String) return null;
  return (photoUrl: photo, note: note);
}

class PageDto<T> {
  const PageDto({
    required this.items,
    required this.page,
    required this.pageSize,
    this.total,
    this.unreadCount,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int? total;
  final int? unreadCount;

  static PageDto<T>? fromJson<T>(
    Map<String, Object?> json, {
    required T? Function(Map<String, Object?>) itemFromJson,
  }) {
    if (json case {
      'items': final List<Object?> itemsJson,
      'page': final int page,
      'pageSize': final int pageSize,
    }) {
      final metadata = _pageMetadataFromJson(json);
      if (metadata == null) return null;
      final items = _pageItemsFromJson(itemsJson, itemFromJson);
      if (items == null) return null;
      return PageDto<T>(
        items: items,
        page: page,
        pageSize: pageSize,
        total: metadata.total,
        unreadCount: metadata.unreadCount,
      );
    }
    return null;
  }

  Map<String, Object?> toJson({required Object? Function(T) itemToJson}) => {
    'items': [for (final item in items) itemToJson(item)],
    'page': page,
    'pageSize': pageSize,
    if (total != null) 'total': total,
    if (unreadCount != null) 'unreadCount': unreadCount,
  };
}

({int? total, int? unreadCount})? _pageMetadataFromJson(
  Map<String, Object?> json,
) {
  final hasTotal = json.containsKey('total');
  final hasUnreadCount = json.containsKey('unreadCount');
  if (hasTotal == hasUnreadCount) return null;

  if (hasTotal) {
    final total = json['total'];
    if (total is! int) return null;
    return (total: total, unreadCount: null);
  }

  final unreadCount = json['unreadCount'];
  if (unreadCount is! int) return null;
  return (total: null, unreadCount: unreadCount);
}

List<T>? _pageItemsFromJson<T>(
  List<Object?> json,
  T? Function(Map<String, Object?>) itemFromJson,
) {
  final items = <T>[];
  for (final itemJson in json) {
    if (itemJson is! Map<String, Object?>) return null;
    final item = itemFromJson(itemJson);
    if (item == null) return null;
    items.add(item);
  }
  return items;
}

class NotificationDto {
  const NotificationDto({
    required this.notificationId,
    required this.reportId,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.readAt,
  });

  final String notificationId;
  final String reportId;
  final String type;
  final String message;
  final DateTime createdAt;
  final DateTime? readAt;

  static NotificationDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'notificationId': final String notificationId,
      'reportId': final String reportId,
      'type': final String type,
      'message': final String message,
      'createdAt': final String createdAtValue,
    }) {
      final createdAt = DateTime.tryParse(createdAtValue);
      if (createdAt == null) return null;

      DateTime? readAt;
      if (json case {'readAt': final String value}) {
        readAt = DateTime.tryParse(value);
        if (readAt == null) return null;
      } else if (json case {'readAt': null}) {
        readAt = null;
      } else {
        return null;
      }

      return NotificationDto(
        notificationId: notificationId,
        reportId: reportId,
        type: type,
        message: message,
        createdAt: createdAt,
        readAt: readAt,
      );
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'notificationId': notificationId,
    'reportId': reportId,
    'type': type,
    'message': message,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'readAt': readAt?.toUtc().toIso8601String(),
  };
}

class BuildingDto {
  const BuildingDto({
    required this.buildingId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String buildingId;
  final String name;
  final double latitude;
  final double longitude;

  static BuildingDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'buildingId': final String buildingId,
      'name': final String name,
      'latitude': final num latitude,
      'longitude': final num longitude,
    }) {
      if (!latitude.isFinite || !longitude.isFinite) return null;
      return BuildingDto(
        buildingId: buildingId,
        name: name,
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      );
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'buildingId': buildingId,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class ApiErrorDetailDto {
  const ApiErrorDetailDto({
    required this.code,
    required this.message,
    required this.details,
  });

  final String code;
  final String message;
  final String? details;

  static ApiErrorDetailDto? fromJson(Map<String, Object?> json) {
    if (json case {
      'code': final String code,
      'message': final String message,
      'details': final String? details,
    }) {
      return ApiErrorDetailDto(code: code, message: message, details: details);
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'code': code,
    'message': message,
    'details': details,
  };
}

class ApiErrorDto {
  const ApiErrorDto({required this.error});

  final ApiErrorDetailDto error;

  static ApiErrorDto? fromJson(Map<String, Object?> json) {
    if (json case {'error': final Map<String, Object?> errorJson}) {
      final error = ApiErrorDetailDto.fromJson(errorJson);
      if (error == null) return null;
      return ApiErrorDto(error: error);
    }
    return null;
  }

  Map<String, Object?> toJson() => {'error': error.toJson()};
}
