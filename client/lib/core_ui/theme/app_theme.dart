import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Bare Material 3 baseline.
//
// This file is intentionally minimal. Run /setup-design-system to replace
// these placeholder seeds with a project-specific palette, typography scale,
// spacing tokens, and custom components created by ui-ux-pro-max.
//
// DO NOT hand-edit token values here — let the skill generate them so the
// entire design system is consistent and tailored to the product.
// ---------------------------------------------------------------------------

// TODO(setup-design-system): replace with project brand color
const Color _seedColor = Color(0xFF6750A4);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
);
