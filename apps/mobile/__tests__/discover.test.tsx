import { render, screen } from '@testing-library/react-native';
import Screen from '../app/(tabs)/discover';
import i18n from '@/i18n';

test('discover screen renders translated placeholder', async () => {
  await i18n.changeLanguage('en');
  await render(<Screen />);
  expect(screen.getByRole('header')).toBeTruthy();
  expect(screen.getByText('Coming soon')).toBeTruthy();
});
