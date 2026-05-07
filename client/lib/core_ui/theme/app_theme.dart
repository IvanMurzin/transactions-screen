import 'package:flutter/material.dart';

import 'package:template_app/core_ui/theme/ds_theme.dart';

// ---------------------------------------------------------------------------
// Neutral placeholder palette.
//
// This is intentionally a desaturated greyscale + a single accent. Replace
// these tokens with your product's brand palette in `_lightColors` /
// `_darkColors` below — the rest of the design system reads them through
// `context.dsColors`, so a single edit cascades to every component.
// ---------------------------------------------------------------------------

const DSSpacing _spacing = DSSpacing(s4: 4, s8: 8, s12: 12, s16: 16, s24: 24, s32: 32);

const DSRadius _radius = DSRadius(r8: 8, r12: 12, r16: 16);

const DSElevation _elevation = DSElevation(
  e0: [],
  e1: [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -4,
    ),
  ],
  e2: [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.14),
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -6,
    ),
  ],
);

const DSColors _lightColors = DSColors(
  primary: Color(0xFF1F2937),
  primaryHover: Color(0xFF111827),
  onPrimary: Color(0xFFFFFFFF),
  background: Color(0xFFF8FAFC),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFF1F5F9),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF475569),
  textTertiary: Color(0xFF94A3B8),
  textOnPrimary: Color(0xFFFFFFFF),
  border: Color(0xFFE2E8F0),
  success: Color(0xFF16A34A),
  warning: Color(0xFFD97706),
  danger: Color(0xFFDC2626),
  info: Color(0xFF0284C7),
  neutral0: Color(0xFFFFFFFF),
  neutral50: Color(0xFFF8FAFC),
  neutral100: Color(0xFFF1F5F9),
  neutral200: Color(0xFFE2E8F0),
  neutral300: Color(0xFFCBD5E1),
  neutral400: Color(0xFF94A3B8),
  neutral500: Color(0xFF64748B),
  neutral600: Color(0xFF475569),
  neutral700: Color(0xFF334155),
  neutral900: Color(0xFF0F172A),
  neutral950: Color(0xFF020617),
);

const DSColors _darkColors = DSColors(
  primary: Color(0xFFE2E8F0),
  primaryHover: Color(0xFFFFFFFF),
  onPrimary: Color(0xFF0F172A),
  background: Color(0xFF020617),
  surface: Color(0xFF0F172A),
  surfaceAlt: Color(0xFF1E293B),
  textPrimary: Color(0xFFF8FAFC),
  textSecondary: Color(0xFFCBD5E1),
  textTertiary: Color(0xFF94A3B8),
  textOnPrimary: Color(0xFF0F172A),
  border: Color(0xFF1E293B),
  success: Color(0xFF22C55E),
  warning: Color(0xFFF59E0B),
  danger: Color(0xFFF87171),
  info: Color(0xFF38BDF8),
  neutral0: Color(0xFFFFFFFF),
  neutral50: Color(0xFFF8FAFC),
  neutral100: Color(0xFFF1F5F9),
  neutral200: Color(0xFFE2E8F0),
  neutral300: Color(0xFFCBD5E1),
  neutral400: Color(0xFF94A3B8),
  neutral500: Color(0xFF64748B),
  neutral600: Color(0xFF475569),
  neutral700: Color(0xFF334155),
  neutral900: Color(0xFF0F172A),
  neutral950: Color(0xFF020617),
);

final ThemeData lightTheme = _buildTheme(_lightColors, Brightness.light);
final ThemeData darkTheme = _buildTheme(_darkColors, Brightness.dark);

ThemeData _buildTheme(DSColors colors, Brightness brightness) {
  final typography = DSTypography.fromColors(colors);

  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryHover,
      onPrimaryContainer: colors.onPrimary,
      secondary: colors.info,
      onSecondary: colors.onPrimary,
      secondaryContainer: colors.surfaceAlt,
      onSecondaryContainer: colors.textPrimary,
      tertiary: colors.success,
      onTertiary: colors.onPrimary,
      tertiaryContainer: colors.success,
      onTertiaryContainer: colors.onPrimary,
      error: colors.danger,
      onError: colors.onPrimary,
      errorContainer: colors.danger,
      onErrorContainer: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceAlt,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.border,
      shadow: colors.neutral950,
      scrim: colors.neutral950,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.surface,
      inversePrimary: colors.primary,
      surfaceTint: colors.primary,
    ),
    scaffoldBackgroundColor: colors.background,
    textTheme: typography.toTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      titleTextStyle: typography.h2.copyWith(color: colors.textPrimary),
      iconTheme: IconThemeData(color: colors.textPrimary),
    ),
    dividerTheme: DividerThemeData(color: colors.border, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius.r12)),
      titleTextStyle: typography.h2.copyWith(color: colors.textPrimary),
      contentTextStyle: typography.body.copyWith(color: colors.textSecondary),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius.r12)),
    ),
    extensions: [colors, _spacing, _radius, _elevation, typography],
  );
}
