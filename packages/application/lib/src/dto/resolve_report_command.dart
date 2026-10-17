final class ResolveReportCommand {
  const ResolveReportCommand({
    required this.reportId,
    required this.assigneeId,
    required this.role,
    this.resolutionPhotoUrl,
    this.resolutionPhotoContentType,
    this.resolutionPhotoSizeBytes,
    this.note,
  });

  final String reportId;
  final String assigneeId;
  final String role;
  final String? resolutionPhotoUrl;
  final String? resolutionPhotoContentType;
  final int? resolutionPhotoSizeBytes;
  final String? note;
}
