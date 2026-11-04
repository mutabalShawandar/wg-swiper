import de from '../src/i18n/de.json';
import en from '../src/i18n/en.json';

const keys = (o: object, p = ''): string[] =>
  Object.entries(o).flatMap(([k, v]) =>
    typeof v === 'object' && v !== null ? keys(v, `${p}${k}.`) : [`${p}${k}`],
  );

test('de and en have identical keys', () => {
  expect(keys(de).sort()).toEqual(keys(en).sort());
});
