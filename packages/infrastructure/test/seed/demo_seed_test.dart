// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
// Demo seed'i (db/seed/002_demo.sql) bir işlem içinde yükler, denetler ve geri alır;
// veritabanında hiçbir şey kalmaz.
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

const _sampleSeed = '../../db/seed/001_ornek.sql';
const _demoSeed = '../../db/seed/002_demo.sql';

// 001'in ilk binası: veritabanında varsa 001 daha önce yüklenmiştir.
const _sampleBuilding = 'b0000000-0000-4000-8000-000000000001';

// Demo bildirimlerinin kimlikleri bu önekle başlar.
const _demo = "r.report_id::text LIKE 'c0000000-0000-4000-8000-0000000002%'";

// LocalFileStorage'ın verdiği dosya adı: 32 onaltılık karakter ve uzantı.
const _storedName = r"'/[0-9a-f]{32}\.(jpg|png)$'";

// Her sorgu kurala uymayan demo bildirimlerini sayar; sonuç 0 olmalı.
const _brokenRows = {
  // İlk geçmiş satırı boş -> Yeni ve bildiren kişi; son satır şu anki durum.
  'history_startsAtYeni_andEndsAtCurrentStatus':
      '''
SELECT count(*)::int FROM reports r WHERE $_demo AND (
  (SELECT h.from_status IS NULL AND h.to_status = 'Yeni' AND h.changed_by = r.reporter_id
     FROM status_history h WHERE h.report_id = r.report_id
     ORDER BY h.changed_at LIMIT 1) IS NOT TRUE
  OR (SELECT h.to_status FROM status_history h WHERE h.report_id = r.report_id
     ORDER BY h.changed_at DESC LIMIT 1) IS DISTINCT FROM r.status)''',
  // Rule 04: çözülende bildirene tek haber, diğerlerinde hiç haber yok.
  'resolved_haveOneNotificationForReporter_othersNone':
      '''
SELECT count(*)::int FROM reports r WHERE $_demo AND
  (SELECT count(*) FROM notifications n WHERE n.report_id = r.report_id
     AND n.user_id = r.reporter_id) <> CASE WHEN r.status = 'Cozuldu' THEN 1 ELSE 0 END
  OR $_demo AND EXISTS (SELECT 1 FROM notifications n
     WHERE n.report_id = r.report_id AND n.user_id <> r.reporter_id)''',
  // Rule 00: bildirimleri öğrenciler açar, yalnızca görevliler üstlenir.
  'roles_studentsReport_staffAssign': '''
SELECT count(*)::int FROM reports r
JOIN users reporter ON reporter.user_id = r.reporter_id
LEFT JOIN users assignee ON assignee.user_id = r.assignee_id
WHERE $_demo AND (reporter.role <> 'Student' OR assignee.role <> 'Staff')''',
  // Fotoğraf adresleri sunucunun ürettiği biçimde: yoksa dosya bulunsa da
  // sunucu açmaz (LocalFileStorage) ve demoda resim görünmez.
  'photoUrls_matchStorageFormat':
      '''
SELECT count(*)::int FROM reports r WHERE $_demo AND (
  r.photo_url !~ ('^/files/' || r.report_id::text || $_storedName)
  OR r.resolution_photo_url !~ ('^/files/' || r.report_id::text || $_storedName))''',
  // Rule 06: bina kaynağında konum, kayıtlı bina koordinatıdır.
  'buildingSource_usesBuildingCoordinates':
      '''
SELECT count(*)::int FROM reports r JOIN buildings b USING (building_id)
WHERE $_demo AND r.location_source = 'Building'
  AND (r.latitude <> b.latitude OR r.longitude <> b.longitude)''',
  // Tarih gelecekte değil; açılış <= üstlenme <= çözülme <= haber <= okunma.
  'dates_areInThePast_andInOrder':
      '''
SELECT count(*)::int FROM reports r
LEFT JOIN notifications n USING (report_id)
WHERE $_demo AND (r.created_at > NOW() OR r.taken_at < r.created_at
  OR r.taken_at > NOW() OR r.resolved_at < r.taken_at OR r.resolved_at > NOW()
  OR n.created_at < r.resolved_at OR n.read_at < n.created_at)''',
};

// Seed kimlikleri ...00X (001) ve ...2XX (002 bildirimleri); testlerin kendi
// satırları ...0a1 gibi biter. Yalnızca seed satırları sayılır: paralel çalışan
// başka test dosyaları tabloya satır ekleyince sayım bozulmasın.
const _seedId =
    r"~ '^[abc]0000000-0000-4000-8000-0000000(0000[0-9a]|002[0-9a-f]{2})$'";

const _tableCounts = [
  'SELECT count(*)::int FROM buildings WHERE building_id::text $_seedId',
  'SELECT count(*)::int FROM users WHERE user_id::text $_seedId',
  'SELECT count(*)::int FROM reports WHERE report_id::text $_seedId',
  'SELECT count(*)::int FROM status_history WHERE report_id::text $_seedId',
  'SELECT count(*)::int FROM notifications WHERE report_id::text $_seedId',
];

final class _Rollback implements Exception {}

// Seed dosyası kendi BEGIN/COMMIT satırlarını taşır; test kendi işlemini
// açtığı için bu satırlar çıkarılır, geri kalan SQL olduğu gibi çalışır.
String _withoutTransaction(String path) =>
    File(path)
        .readAsLinesSync()
        .where((line) => line.trim() != 'BEGIN;' && line.trim() != 'COMMIT;')
        .join('\n');

Future<void> _runFile(TxSession tx, String path) =>
    tx.execute(_withoutTransaction(path), queryMode: QueryMode.simple);

Future<int> _count(TxSession tx, String sql) async {
  final rows = await tx.execute(sql);
  return rows.first.first! as int;
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('demo seed (002_demo.sql)', () {
    late Database db;

    setUpAll(() => db = Database.fromUrl(url!));
    tearDownAll(() => db.close());

    // [check] demo verisi yüklüyken çalışır; sonunda her şey geri alınır.
    Future<void> withDemo(Future<void> Function(TxSession tx) check) async {
      try {
        await db.transaction((tx) async {
          final sampleLoaded = await _count(
            tx,
            "SELECT count(*)::int FROM buildings WHERE building_id = '$_sampleBuilding'",
          );
          if (sampleLoaded == 0) await _runFile(tx, _sampleSeed);
          await _runFile(tx, _demoSeed);
          await check(tx);
          throw _Rollback();
        });
      } on _Rollback {
        return;
      }
    }

    test('load_onTopOfSample_passesAllConstraints', () async {
      await withDemo((tx) async {
        final byStatus = await tx.execute(
          'SELECT status, count(*)::int FROM reports r WHERE $_demo '
          'GROUP BY status ORDER BY status',
        );
        expect(
          {for (final r in byStatus) r[0]: r[1]},
          {'Cozuldu': 3, 'Ustlenildi': 3, 'Yeni': 4},
        );
        // İki konum kaynağı da denensin diye: binadan ve GPS'ten bildirim var.
        final sources = await tx.execute(
          'SELECT DISTINCT location_source FROM reports r WHERE $_demo ORDER BY 1',
        );
        expect([for (final r in sources) r[0]], ['Building', 'Gps']);
      });
    });

    test('loadTwice_addsNothing', () async {
      await withDemo((tx) async {
        Future<List<int>> counts() async => [
          for (final sql in _tableCounts) await _count(tx, sql),
        ];
        final before = await counts();
        // Desen seed satırlarını gerçekten buluyor mu: hiçbir sayı 0 olmamalı.
        expect(before, everyElement(greaterThan(0)));
        await _runFile(tx, _demoSeed);
        expect(await counts(), before);
      });
    });

    for (final MapEntry(key: name, value: sql) in _brokenRows.entries) {
      test(name, () async {
        await withDemo((tx) async => expect(await _count(tx, sql), 0));
      });
    }
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
