import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:transaction_screen/core_ui/theme/theme_mode_cubit.dart';
import 'package:transaction_screen/l10n/app_localizations.dart';

class ThemeModeMenuButton extends StatelessWidget {
  const ThemeModeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mode = context.watch<ThemeModeCubit>().state;

    return PopupMenuButton<ThemeMode>(
      icon: Icon(_iconFor(mode)),
      tooltip: l10n.settingsTheme,
      onSelected: (selected) => context.read<ThemeModeCubit>().set(selected),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: ThemeMode.system,
          checked: mode == ThemeMode.system,
          child: Text(l10n.themeSystem),
        ),
        CheckedPopupMenuItem(
          value: ThemeMode.light,
          checked: mode == ThemeMode.light,
          child: Text(l10n.themeLight),
        ),
        CheckedPopupMenuItem(
          value: ThemeMode.dark,
          checked: mode == ThemeMode.dark,
          child: Text(l10n.themeDark),
        ),
      ],
    );
  }

  IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }
}
