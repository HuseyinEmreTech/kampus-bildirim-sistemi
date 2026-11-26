import {
  readFilters,
  totalPages,
  renderReportList,
  renderPagination,
  normalizeBuildings,
  markBuildingFilterPending,
} from '../js/reports.js';
import { test, assertEqual, assertTrue } from './harness.js';

const REPORT = {
  reportId: 'r1',
  category: 'Ariza',
  description: 'B blok 2. kat koridor lambası yanmıyor',
  place: 'B Blok 2. kat',
  status: 'Yeni',
  createdAt: '2026-10-02T09:15:00Z',
};

test('filtreler adres çubuğundan okunur', () => {
  const filters = readFilters('?status=Cozuldu&category=Temizlik&buildingId=b2&page=3&pageSize=50');
  assertEqual(filters, { status: 'Cozuldu', category: 'Temizlik', buildingId: 'b2', page: 3, pageSize: 50 });
});

test('geçersiz filtre ve sayfa değerleri varsayılana döner', () => {
  const filters = readFilters('?status=Bilinmiyor&category=x&page=-4&pageSize=1000');
  assertEqual(filters, { status: '', category: '', buildingId: '', page: 1, pageSize: 20 });
});

test('toplam sayfa sayısı en az 1 olur', () => {
  assertEqual(totalPages(0, 20), 1);
  assertEqual(totalPages(41, 20), 3);
});

test('bina listesi sunucunun { items } biçiminden okunur', () => {
  const raw = [{ buildingId: 'b1', name: 'A Blok' }];
  assertEqual(normalizeBuildings({ items: raw }), raw);
  assertEqual(normalizeBuildings(raw), [], 'düz dizi sunucu biçimi değil');
  assertEqual(normalizeBuildings(null), []);
});

// Sunucu buildingId süzgecini #160 gelene dek tanımıyor; seçen kişi liste değişmeyince hata sanmasın.
test('bina süzgeci sunucu desteklemeyene dek devre dışı ve "yakında" yazar', () => {
  const label = document.createElement('label');
  label.textContent = 'Bina';
  const select = document.createElement('select');
  select.add(new Option('Tümü', ''));
  select.add(new Option('A Blok', 'b1'));
  select.value = 'b1';
  label.append(select);
  markBuildingFilterPending(select);
  assertEqual(select.disabled, true);
  assertEqual(select.value, '');
  assertTrue(label.textContent.includes('yakında'), `etiket: ${label.textContent}`);
});

test('bildirimler kart olarak çizilir, etiketler Türkçedir', () => {
  const container = document.createElement('div');
  renderReportList(container, [REPORT]);
  const cards = container.querySelectorAll('.report-card');
  assertEqual(cards.length, 1);
  assertTrue(cards[0].textContent.includes('Arıza'), 'kategori etiketi');
  assertTrue(cards[0].textContent.includes('Yeni'), 'durum etiketi');
  assertTrue(cards[0].textContent.includes('B Blok 2. kat'), 'konum');
});

// Sunucunun gerçek yanıtı (report_mapper.dart): konum düz `place` ve `buildingName` alanlarıyla gelir.
const SERVER_REPORT = {
  reportId: 'r2',
  category: 'Temizlik',
  description: 'Kütüphane girişinde çöp kutusu taşmış',
  status: 'Ustlenildi',
  place: 'Kütüphane girişi',
  buildingName: 'Kütüphane',
  photoUrl: '/files/abc.jpg',
  assigneeId: 'u9',
  createdAt: '2026-11-02T10:00:00.000Z',
};

test('sunucu biçiminde konum place alanından okunur', () => {
  const container = document.createElement('div');
  renderReportList(container, [SERVER_REPORT]);
  const meta = container.querySelector('.report-card__meta').textContent;
  assertTrue(meta.startsWith('Kütüphane girişi'), `konum: ${meta}`);
});

test('place yoksa bina adı gösterilir', () => {
  const container = document.createElement('div');
  renderReportList(container, [{ ...SERVER_REPORT, place: null }]);
  const meta = container.querySelector('.report-card__meta').textContent;
  assertTrue(meta.startsWith('Kütüphane ·'), `konum: ${meta}`);
});

test('açıklama HTML olarak yorumlanmaz', () => {
  const container = document.createElement('div');
  renderReportList(container, [{ ...REPORT, description: '<img src=x onerror=alert(1)>' }]);
  assertEqual(container.querySelectorAll('img').length, 0);
});

test('liste boşsa boş durum mesajı gösterilir', () => {
  const container = document.createElement('div');
  renderReportList(container, []);
  assertTrue(container.querySelector('.state-empty') !== null, 'boş durum öğesi olmalı');
});

test('sayfalama düğmeleri sınırda devre dışı kalır', () => {
  const container = document.createElement('nav');
  const pages = [];
  renderPagination(container, { page: 1, pageSize: 20, total: 45 }, (p) => pages.push(p));
  const [prev, next] = container.querySelectorAll('button');
  assertEqual(prev.disabled, true);
  assertEqual(next.disabled, false);
  assertTrue(container.textContent.includes('1 / 3'), 'sayfa bilgisi');
  next.click();
  assertEqual(pages, [2]);
});
