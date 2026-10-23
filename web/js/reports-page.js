import { reportQuery } from './api.js';
import {
  CATEGORY_LABELS,
  STATUS_LABELS,
  normalizeBuildings,
  readFilters,
  renderPagination,
  renderReportList,
  renderState,
} from './reports.js';
import { api, redirectToLogin, store } from './session.js';

const form = document.getElementById('filtreler');
const list = document.getElementById('liste');
const pagination = document.getElementById('sayfalama');

let filters = readFilters(location.search);
let buildings = [];

function addOptions(select, entries) {
  for (const [value, label] of entries) select.add(new Option(label, value));
}

function errorMessage(error) {
  if (error.code === 'FORBIDDEN') return 'Bu liste yalnızca görevliler içindir.';
  if (error.code === 'NETWORK_ERROR') return 'Sunucuya ulaşılamadı. Bağlantını kontrol edip sayfayı yenile.';
  return error.message;
}

async function loadReports() {
  history.replaceState(null, '', `?${reportQuery(filters)}`);
  renderState(list, 'loading', 'Yükleniyor…');
  pagination.replaceChildren();
  const result = await api.listReports(filters);
  if (!result.ok) {
    renderState(list, 'error', errorMessage(result.error));
    return;
  }
  const { items = [], page = filters.page, pageSize = filters.pageSize, total = 0 } = result.data ?? {};
  renderReportList(list, items, buildings);
  if (total > 0) renderPagination(pagination, { page, pageSize, total }, goToPage);
}

function goToPage(page) {
  filters = { ...filters, page };
  loadReports();
  window.scrollTo({ top: 0 });
}

async function loadBuildings() {
  const result = await api.listBuildings();
  if (!result.ok) return;
  buildings = normalizeBuildings(result.data);
  addOptions(form.buildingId, buildings.map((b) => [b.buildingId, b.name]));
  form.buildingId.value = filters.buildingId;
}

function start() {
  if (!store.hasSession()) {
    redirectToLogin();
    return;
  }
  document.getElementById('kullanici').textContent = store.user()?.fullName ?? '';
  document.getElementById('cikis').addEventListener('click', () => {
    store.clear();
    redirectToLogin();
  });

  addOptions(form.status, Object.entries(STATUS_LABELS));
  addOptions(form.category, Object.entries(CATEGORY_LABELS));
  form.status.value = filters.status;
  form.category.value = filters.category;
  form.addEventListener('change', () => {
    filters = { ...filters, ...Object.fromEntries(new FormData(form)), page: 1 };
    loadReports();
  });

  loadBuildings().then(loadReports);
}

start();
