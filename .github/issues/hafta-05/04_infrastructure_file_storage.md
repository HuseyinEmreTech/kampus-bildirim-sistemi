# Issue #4: FileStorage - Foto Kaydet, 5MB Limit, EXIF Temizle

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @ertrlpkdmr
**Etiketler:** `infrastructure`, `feat`, `sart`
**Branch:** `feature/hafta05-file-storage`

## Kabul Ölçütleri
- [ ] `FileStorage.saveReportPhoto(ReportId, Stream<List<int>>, String contentType)` → `Result<Photo, AppError>`
  - **Magic bytes** kontrolü: JPEG (FF D8 FF) / PNG (89 50 4E 47) - uzantıya güvenme
  - **5MB limit**: Stream okurken byte sayacı, limit aşıldığında hata
  - **EXIF temizleme**: `image` paketi veya `exiftool` CLI wrapper ile strip
  - **Dosya adı**: `{reportId}/{uuid}.{ext}` (uuid v7 timestampli)
  - **Dönüş**: `Photo(url, contentType, sizeBytes)` - url: `/files/{path}`
- [ ] `FileStorage.saveResolutionPhoto(ReportId, Stream, contentType)` → `Result<Photo, AppError>`
  - Aynı kurallar, eski resolution photo varsa sil
- [ ] `FileStorage.delete(String url)` → `Result<Unit, AppError>`
- [ ] `FileStorage.getStream(String url)` → `Stream<List<int>>` (serve için)

## Dokunulacak Dosyalar
```
packages/infrastructure/lib/src/storage/
├── file_storage.dart (interface - Application katmanında)
├── local_file_storage.dart (implementation)
├── image_validator.dart (magic bytes, size, EXIF)
└── photo.dart (mapper)
```

## Dokunulmayacak Dosyalar
- `packages/domain/` - Photo value object (zaten var)
- `packages/application/` - FileStorage interface (Application'da tanımlı)
- `packages/server/` - Static file serve endpoint (Server'da)

## Bağlı Testler
- `packages/infrastructure/test/storage/file_storage_test.dart`
  - `save_validJpeg_returnsPhoto`
  - `save_invalidMagicBytes_returnsInvalidFormat`
  - `save_over5MB_returnsSizeExceeded`
  - `save_stripsExif_dataRemoved`
  - `save_png_works`
  - `delete_existingFile_removesFile`

## Teknik Detaylar
```dart
// Magic bytes kontrolü (ilk 12 byte yeterli)
final jpegSignature = [0xFF, 0xD8, 0xFF];
final pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

// EXIF temizleme - image paketi ile (pure Dart, CLI bağımlılığı yok)
import 'package:image/image.dart' as img;
img.Image? image = img.decodeImage(bytes);
if (image != null) {
  // EXIF verisi otomatik atılır encode ederken
  final cleanBytes = img.encodeJpg(image, quality: 85);
}
```

## Konfigürasyon
- Depolama yolu: `config.fileStoragePath` (env: `FILE_STORAGE_PATH`, default: `./storage`)
- Max dosya boyutu: `config.maxPhotoSizeBytes = 5 * 1024 * 1024` (5MB)
- İzinli content-type: `image/jpeg`, `image/png`

## Notlar
- Sunucu diskinde saklama (MVP), gelecekte S3/R2 için interface hazır
- `dart:io` kullanımı **sadece** `infrastructure` paketinde serbest
- Stream tabanlı okuma/yazma (memory efficient)
- Testlerde `Directory.systemTemp` kullan, cleanup yap