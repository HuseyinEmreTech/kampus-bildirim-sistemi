import { api, safeNext, store } from './session.js';

const form = document.getElementById('giris-formu');
const errorBox = document.getElementById('giris-hatasi');
const submit = form.querySelector('button[type="submit"]');

const MESSAGES = {
  INVALID_CREDENTIALS: 'E-posta veya parola hatalı.',
  NETWORK_ERROR: 'Sunucuya ulaşılamadı. Sunucunun çalıştığını kontrol et.',
};

function showError(message) {
  errorBox.textContent = message;
  errorBox.hidden = false;
}

if (store.hasSession()) location.replace(safeNext(location.search));

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  errorBox.hidden = true;
  const email = form.email.value.trim();
  const password = form.password.value;
  if (!email || !password) {
    showError('E-posta ve parola gerekli.');
    return;
  }
  submit.disabled = true;
  const result = await api.login(email, password);
  submit.disabled = false;
  if (!result.ok) {
    showError(MESSAGES[result.error.code] ?? result.error.message);
    return;
  }
  location.assign(safeNext(location.search));
});
