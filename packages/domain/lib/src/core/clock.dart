/// Zamanı dışarıdan almak için arayüz; testlerde sabit saat takılarak
/// belirsizlik kaldırılır.
abstract interface class Clock {
  DateTime now();
}
