// Bildirim listesinin saf yardımcıları ve DOM çizimi. Metinler her zaman textContent ile yazılır (XSS yok).

import { DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE } from './config.js';

/** API değeri -> ekranda görünen etiket (05-api-design parametreleri). */
export const STATUS_LABELS = { Yeni: 'Yeni', Ustlenildi: 'Üstlenildi', Cozuldu: 'Çözüldü' };
export const CATEGORY_LABELS = { Ariza: 'Arıza', Temizlik: 'Temizlik', Guvenlik: 'Güvenlik', Diger: 'Diğer' };

const DATE_FORMAT = new Intl.DateTimeFormat('tr-TR', { dateStyle: 'medium', timeStyle: 'short' });

function positiveInt(value, fallback, max = Number.MAX_SAFE_INTEGER) {
  const number = Number(value);
  if (!Number.isInteger(number) || number < 1 || number > max) return fallback;
  return number;
}

function oneOf(value, labels) {
  return Object.hasOwn(labels, value) ? value : '';
}

/** Adres çubuğundaki sorgudan geçerli filtreleri okur; geçersiz değerler varsayılana döner. */
export function readFilters(search) {
  const params = new URLSearchParams(search);
  return {
    status: oneOf(params.get('status'), STATUS_LABELS),
    category: oneOf(params.get('category'), CATEGORY_LABELS),
    buildingId: params.get('buildingId') ?? '',
    page: positiveInt(params.get('page'), 1),
    pageSize: positiveInt(params.get('pageSize'), DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE),
  };
}

export function totalPages(total, pageSize) {
  return Math.max(1, Math.ceil(total / pageSize));
}

/** /api/buildings yanıtı dizi ya da { items } olabilir (gövde henüz kesinleşmedi). */
export function normalizeBuildings(data) {
  if (Array.isArray(data)) return data;
  return Array.isArray(data?.items) ? data.items : [];
}

function element(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function placeOf(report, buildingNames) {
  const location = report.location ?? {};
  return location.place || buildingNames.get(location.buildingId) || 'Konum belirtilmemiş';
}

function reportCard(report, buildingNames) {
  const card = element('article', 'report-card');
  const header = element('header', 'report-card__header');
  header.append(
    element('span', 'badge badge--category', CATEGORY_LABELS[report.category] ?? report.category),
    element('span', `badge badge--status badge--${report.status}`, STATUS_LABELS[report.status] ?? report.status),
  );
  const meta = element('p', 'report-card__meta');
  meta.textContent = `${placeOf(report, buildingNames)} · ${DATE_FORMAT.format(new Date(report.createdAt))}`;
  card.append(header, element('p', 'report-card__text', report.description), meta);
  return card;
}

/** Bildirim kartlarını çizer; liste boşsa boş durum mesajı gösterir. */
export function renderReportList(container, reports, buildings = []) {
  if (reports.length === 0) {
    renderState(container, 'empty', 'Bu filtrelere uyan bildirim yok.');
    return;
  }
  const buildingNames = new Map(buildings.map((b) => [b.buildingId, b.name]));
  container.replaceChildren(...reports.map((r) => reportCard(r, buildingNames)));
}

/** Yükleniyor, boş ve hata durumları için tek mesaj kutusu. */
export function renderState(container, kind, message) {
  const box = element('p', `state state-${kind}`, message);
  if (kind === 'error') box.setAttribute('role', 'alert');
  container.replaceChildren(box);
}

export function renderPagination(container, { page, pageSize, total }, onPage) {
  const pages = totalPages(total, pageSize);
  const prev = element('button', 'button button--ghost', '‹ Önceki');
  const next = element('button', 'button button--ghost', 'Sonraki ›');
  prev.type = 'button';
  next.type = 'button';
  prev.disabled = page <= 1;
  next.disabled = page >= pages;
  prev.addEventListener('click', () => onPage(page - 1));
  next.addEventListener('click', () => onPage(page + 1));
  const info = element('span', 'pagination__info', `${page} / ${pages} · ${total} bildirim`);
  container.replaceChildren(prev, info, next);
}
