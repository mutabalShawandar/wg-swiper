import { StyleSheet, Text, View } from 'react-native';
import { useTranslation } from 'react-i18next';
import { useTheme } from './theme';

type Props = { titleKey: string };

export function PlaceholderScreen({ titleKey }: Props) {
  const { t } = useTranslation();
  const { colors, spacing, typography } = useTheme();
  return (
    <View style={[styles.root, { backgroundColor: colors.background, padding: spacing.lg }]}>
      <Text accessibilityRole="header" style={[typography.title, { color: colors.text }]}>
        {t(titleKey)}
      </Text>
      <Text style={[typography.body, { color: colors.textMuted, marginTop: spacing.sm }]}>
        {t('common.comingSoon')}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({ root: { flex: 1, justifyContent: 'center' } });
