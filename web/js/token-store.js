// Oturum belirteçlerinin saklanması. Varsayılan depo sessionStorage: sekme kapanınca oturum biter.

const ACCESS_KEY = 'campus.accessToken';
const REFRESH_KEY = 'campus.refreshToken';
const USER_KEY = 'campus.user';

export function createTokenStore(storage = window.sessionStorage) {
  return {
    save({ accessToken, refreshToken, user }) {
      storage.setItem(ACCESS_KEY, accessToken);
      storage.setItem(REFRESH_KEY, refreshToken);
      storage.setItem(USER_KEY, JSON.stringify(user ?? null));
    },
    accessToken: () => storage.getItem(ACCESS_KEY),
    refreshToken: () => storage.getItem(REFRESH_KEY),
    user() {
      try {
        return JSON.parse(storage.getItem(USER_KEY));
      } catch {
        return null;
      }
    },
    hasSession() {
      return storage.getItem(ACCESS_KEY) !== null;
    },
    clear() {
      storage.removeItem(ACCESS_KEY);
      storage.removeItem(REFRESH_KEY);
      storage.removeItem(USER_KEY);
    },
  };
}
