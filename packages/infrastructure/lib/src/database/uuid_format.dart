final _uuid = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// [value] UUID biçiminde mi? Değilse PostgreSQL `uuid` sütununa verilirse hata fırlatır;
/// bu yüzden dışarıdan gelen kimlikler sorgudan önce kontrol edilir.
bool isUuid(String value) => _uuid.hasMatch(value);
