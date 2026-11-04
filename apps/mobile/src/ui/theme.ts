import { useColorScheme } from 'react-native';

export const palette = {
  light: {
    background: '#FFFFFF',
    surface: '#F4F5F7',
    text: '#111827',
    textMuted: '#4B5563',
    primary: '#E11D48',
    border: '#D1D5DB',
  },
  dark: {
    background: '#0B0F14',
    surface: '#161B22',
    text: '#F9FAFB',
    textMuted: '#9CA3AF',
    primary: '#FB7185',
    border: '#30363D',
  },
} as const;

export const spacing = { xs: 4, sm: 8, md: 16, lg: 24, xl: 32 } as const;

export const typography = {
  title: { fontSize: 24, fontWeight: '700' as const },
  body: { fontSize: 16, fontWeight: '400' as const },
  caption: { fontSize: 13, fontWeight: '400' as const },
};

export type Colors = { [K in keyof (typeof palette)['light']]: string };

export function useTheme() {
  const scheme = useColorScheme() === 'dark' ? 'dark' : 'light';
  return { scheme, colors: palette[scheme] as Colors, spacing, typography };
}
