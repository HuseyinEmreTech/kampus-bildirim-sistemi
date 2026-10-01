// Mimari koruma testi: paketlerin birbirine bağımlılığını ve yasak import'ları denetler.
// Kurallar: proje-bilgileri/11-kod-mimarisi-ve-korumalar.md, bölüm 2.
import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// Paket klasörü -> o paketin bağlanabileceği proje paketleri.
const izinliProjeBagimliliklari = <String, Set<String>>{
  'domain': {},
  'contracts': {},
  'application': {'campus_domain'},
  'infrastructure': {'campus_domain', 'campus_application'},
  'server': {
    'campus_domain',
    'campus_application',
    'campus_infrastructure',
    'campus_contracts',
  },
  'app': {'campus_contracts'},
};

/// Hiçbir dış pakete bağlanamayan paketler (yalnızca Dart çekirdeği).
const disPaketYasak = {'domain', 'contracts'};

/// `dart:io` kullanamayan paketler.
const dartIoYasak = {'domain', 'application', 'contracts'};

final _paketImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]package:(\w+)/''',
  multiLine: true,
);
final _dartIoImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]dart:io['"]''',
  multiLine: true,
);

Map<String, dynamic> _pubspec(String klasor) => Map<String, dynamic>.from(
  loadYaml(File('packages/$klasor/pubspec.yaml').readAsStringSync()) as Map,
);

Iterable<File> _dartDosyalari(String klasor) {
  final lib = Directory('packages/$klasor/lib');
  if (!lib.existsSync()) return const [];
  return lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
}

void main() {
  test('kurallar_tumPaketleriKapsar', () {
    final klasorler = Directory('packages')
        .listSync()
        .whereType<Directory>()
        .map((d) => d.uri.pathSegments[d.uri.pathSegments.length - 2])
        .toSet();
    expect(klasorler, izinliProjeBagimliliklari.keys.toSet());
  });

  for (final klasor in izinliProjeBagimliliklari.keys) {
    final kendiAdi = 'campus_$klasor';
    final izinli = izinliProjeBagimliliklari[klasor]!;

    test('${klasor}_pubspecBagimliliklari_izinliOlmali', () {
      final bagimliliklar =
          ((_pubspec(klasor)['dependencies'] as Map?) ?? const {}).keys
              .cast<String>()
              .toSet();
      final proje = bagimliliklar.where((b) => b.startsWith('campus_')).toSet();
      expect(
        proje.difference(izinli),
        isEmpty,
        reason: '$klasor izinsiz proje paketine bağlı',
      );
      if (disPaketYasak.contains(klasor)) {
        expect(
          bagimliliklar,
          isEmpty,
          reason: '$klasor hiçbir pakete bağlanamaz',
        );
      }
    });

    test('${klasor}_importlari_izinliOlmali', () {
      for (final dosya in _dartDosyalari(klasor)) {
        final icerik = dosya.readAsStringSync();
        for (final eslesme in _paketImport.allMatches(icerik)) {
          final paket = eslesme.group(1)!;
          if (paket == kendiAdi || !paket.startsWith('campus_')) continue;
          expect(
            izinli,
            contains(paket),
            reason: '${dosya.path} izinsiz import: $paket',
          );
        }
        if (dartIoYasak.contains(klasor)) {
          expect(
            _dartIoImport.hasMatch(icerik),
            isFalse,
            reason: '${dosya.path} dart:io kullanamaz',
          );
        }
      }
    });
  }
}
