import { createInstance } from 'i18next';
import { initReactI18next } from 'react-i18next';
import { getLocales } from 'expo-localization';
import de from './de.json';
import en from './en.json';

// German is the product default; only switch to English if the device asks for it.
const device = getLocales()[0]?.languageCode ?? 'de';
const lng = device === 'en' ? 'en' : 'de';

const i18n = createInstance();

void i18n.use(initReactI18next).init({
  resources: { de: { translation: de }, en: { translation: en } },
  lng,
  fallbackLng: 'de',
  interpolation: { escapeValue: false },
  initAsync: false,
});

export default i18n;
