final class CreateReportCommand {
  const CreateReportCommand({
    required this.reporterId,
    required this.category,
    required this.description,
    required this.photoUrl,
    required this.photoContentType,
    required this.photoSizeBytes,
    required this.latitude,
    required this.longitude,
    required this.locationSource,
    this.place,
    this.buildingId,
  });

  final String reporterId;
  final String category;
  final String description;
  final String photoUrl;
  final String photoContentType;
  final int photoSizeBytes;
  final double latitude;
  final double longitude;
  final String locationSource;
  final String? place;
  final String? buildingId;
}
