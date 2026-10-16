/// Bir sayfada en çok kaç kayıt döner (05-api-design: `pageSize` en fazla 100).
const maxPageSize = 100;

/// Sayfa sınırları geçerli mi: [limit] 1 ile [maxPageSize] arasında, [offset]
/// negatif değil. Service bunu zaten denetler; depo yine de geçersiz değerle
/// veritabanına gitmez (negatif sayı PostgreSQL hatası, çok büyük sayı ağır sorgu olur).
bool isValidPage(int limit, int offset) =>
    limit >= 1 && limit <= maxPageSize && offset >= 0;
