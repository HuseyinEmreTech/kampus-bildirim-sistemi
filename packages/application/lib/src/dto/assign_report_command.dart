final class AssignReportCommand {
  const AssignReportCommand({
    required this.reportId,
    required this.assigneeId,
    required this.role,
  });

  final String reportId;
  final String assigneeId;
  final String role;
}
