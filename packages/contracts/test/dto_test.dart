import 'package:campus_contracts/campus_contracts.dart';
import 'package:test/test.dart';

void main() {
  group('AuthResponseDto', () {
    const example = {
      'accessToken': '<erisim-belirteci>',
      'refreshToken': '<yenileme-belirteci>',
      'user': {
        'userId': '5c98741b-64c8-49de-9e68-3d7a2f44802b',
        'fullName': 'Ayşe Yılmaz',
        'role': 'Student',
      },
    };

    test('fromJson_readsApiExample', () {
      final dto = AuthResponseDto.fromJson(example);

      expect(dto, isNotNull);
      expect(dto!.toJson(), example);
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(AuthResponseDto.fromJson({}), isNull);
    });
  });

  group('ReportListItemDto', () {
    const example = {
      'reportId': 'd4816d0a-cd8e-4442-98c0-65d3ba11be70',
      'category': 'Ariza',
      'description': 'B blok 2. kat koridor lambası yanmıyor',
      'status': 'Yeni',
      'place': 'B blok 2. kat',
      'buildingName': null,
      'photoUrl': '/photos/1.jpg',
      'assigneeId': null,
      'createdAt': '2026-10-02T09:15:00.000Z',
    };

    test('fromJson_readsApiExample', () {
      final dto = ReportListItemDto.fromJson(example);

      expect(dto, isNotNull);
      expect(dto!.toJson(), example);
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(ReportListItemDto.fromJson({}), isNull);
    });
  });

  group('ReportDetailDto', () {
    const example = {
      'reportId': 'd4816d0a-cd8e-4442-98c0-65d3ba11be70',
      'category': 'Ariza',
      'description': 'B blok 2. kat koridor lambası yanmıyor',
      'status': 'Cozuldu',
      'place': 'B blok 2. kat',
      'buildingName': 'B Blok',
      'photoUrl': '/photos/1.jpg',
      'createdAt': '2026-10-02T09:15:00.000Z',
      'history': [
        {
          'status': 'Yeni',
          'changedAt': '2026-10-02T09:15:00.000Z',
          'note': null,
        },
        {
          'status': 'Cozuldu',
          'changedAt': '2026-10-02T11:40:00.000Z',
          'note': 'Lamba değiştirildi.',
        },
      ],
      'resolutionPhotoUrl': '/photos/resolution-1.jpg',
      'resolutionNote': 'Lamba değiştirildi.',
    };

    test('fromJson_readsApiExample', () {
      final dto = ReportDetailDto.fromJson(example);

      expect(dto, isNotNull);
      expect(dto!.toJson(), example);
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(ReportDetailDto.fromJson({}), isNull);
    });
  });

  group('StatusChangeDto', () {
    const example = {
      'status': 'Cozuldu',
      'changedAt': '2026-10-02T11:40:00.000Z',
      'note': 'Lamba değiştirildi.',
    };

    test('fromJson_readsApiExample', () {
      final dto = StatusChangeDto.fromJson(example);

      expect(dto, isNotNull);
      expect(dto!.toJson(), example);
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(StatusChangeDto.fromJson({}), isNull);
    });
  });

  group('PageDto<ReportListItemDto>', () {
    const example = {
      'items': [
        {
          'reportId': 'd4816d0a-cd8e-4442-98c0-65d3ba11be70',
          'category': 'Ariza',
          'description': 'B blok 2. kat koridor lambası yanmıyor',
          'status': 'Yeni',
          'place': 'B blok 2. kat',
          'buildingName': null,
          'photoUrl': '/photos/1.jpg',
          'assigneeId': null,
          'createdAt': '2026-10-02T09:15:00.000Z',
        },
      ],
      'page': 1,
      'pageSize': 20,
      'total': 1,
    };

    test('fromJson_readsApiExample', () {
      final dto = PageDto.fromJson<ReportListItemDto>(
        example,
        itemFromJson: ReportListItemDto.fromJson,
      );

      expect(dto, isNotNull);
      expect(
        dto!.toJson(itemToJson: (item) => item.toJson()),
        example,
      );
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(
        PageDto.fromJson<ReportListItemDto>(
          {},
          itemFromJson: ReportListItemDto.fromJson,
        ),
        isNull,
      );
    });
  });

  group('NotificationDto', () {
    const example = {
      'notificationId': '8a1f0c3e-5b7d-4c21-9e4a-2f6b7d9c1a10',
      'reportId': 'd4816d0a-cd8e-4442-98c0-65d3ba11be70',
      'type': 'ReportResolved',
      'message': 'Bildiriminiz çözüldü: B blok 2. kat koridor lambası',
      'createdAt': '2026-10-02T11:40:00.000Z',
      'readAt': null,
    };

    test('fromJson_readsApiExample', () {
      final dto = NotificationDto.fromJson(example);

      expect(dto, isNotNull);
      expect(dto!.toJson(), example);
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(NotificationDto.fromJson({}), isNull);
    });
  });

  group('BuildingDto', () {
    const example = {
      'buildingId': 'a0000000-0000-4000-8000-000000000003',
      'name': 'B Blok',
      'latitude': 36.5871,
      'longitude': 36.1742,
    };

    test('fromJson_readsApiExample', () {
      final dto = BuildingDto.fromJson(example);

      expect(dto, isNotNull);
      expect(dto!.toJson(), example);
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(BuildingDto.fromJson({}), isNull);
    });
  });

  group('ApiErrorDto', () {
    const example = {
      'error': {
        'code': 'VALIDATION_ERROR',
        'message': 'Açıklama en az 5 karakter olmalı.',
        'details': 'description',
      },
    };

    test('fromJson_readsApiExample', () {
      final dto = ApiErrorDto.fromJson(example);

      expect(dto, isNotNull);
      expect(dto!.toJson(), example);
    });

    test('fromJson_returnsNull_onMissingField', () {
      expect(ApiErrorDto.fromJson({}), isNull);
    });
  });
}
