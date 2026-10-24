// Bağımlılıksız küçük test aracı: testleri sırayla çalıştırır, sonucu sayfaya yazar.
// Sonuç ayrıca `document.body.dataset.result` alanına (`pass` / `fail`) konur.

const tests = [];

export function test(name, fn) {
  tests.push({ name, fn });
}

export function assertEqual(actual, expected, message = '') {
  const a = JSON.stringify(actual);
  const e = JSON.stringify(expected);
  if (a !== e) {
    throw new Error(`${message} beklenen ${e}, gelen ${a}`.trim());
  }
}

export function assertTrue(value, message = 'Koşul sağlanmadı.') {
  if (!value) throw new Error(message);
}

export async function run(output) {
  let failed = 0;
  for (const { name, fn } of tests) {
    const line = document.createElement('li');
    try {
      await fn();
      line.textContent = `✓ ${name}`;
      line.className = 'pass';
    } catch (error) {
      failed += 1;
      line.textContent = `✗ ${name}: ${error.message}`;
      line.className = 'fail';
    }
    output.append(line);
  }
  const summary = document.createElement('p');
  summary.textContent = `${tests.length - failed}/${tests.length} test geçti.`;
  output.before(summary);
  document.body.dataset.result = failed === 0 ? 'pass' : 'fail';
}

/** Sabit yanıtlar dönen sahte fetch; yapılan istekleri `calls` içinde tutar. */
export function fakeFetch(responses) {
  const calls = [];
  const fn = async (url, options = {}) => {
    calls.push({ url, options });
    const next = responses.shift();
    if (next instanceof Error) throw next;
    return new Response(next.body === undefined ? null : JSON.stringify(next.body), {
      status: next.status,
      headers: { 'Content-Type': 'application/json' },
    });
  };
  fn.calls = calls;
  return fn;
}

/** sessionStorage yerine bellekte duran depo. */
export function memoryStorage() {
  const map = new Map();
  return {
    getItem: (key) => (map.has(key) ? map.get(key) : null),
    setItem: (key, value) => map.set(key, String(value)),
    removeItem: (key) => map.delete(key),
  };
}
