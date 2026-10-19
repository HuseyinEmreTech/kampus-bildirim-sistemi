/// Tarihi telefonun saatine göre gün.ay.yıl biçiminde yazar
/// (ek paket kullanmamak için elle).
String formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}';
}
