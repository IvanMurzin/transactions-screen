import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:transaction_screen/core/localization/locale_cubit.dart';
import 'package:transaction_screen/l10n/app_localizations.dart';

class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeTag = context.watch<LocaleCubit>().state.localeTag;
    final effectiveTag = activeTag ?? Localizations.localeOf(context).languageCode;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate_outlined),
      tooltip: l10n.settingsLanguage,
      onSelected: (tag) => context.read<LocaleCubit>().setLocale(Locale(tag)),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: 'en',
          checked: effectiveTag == 'en',
          child: Text(l10n.languageEnglish),
        ),
        CheckedPopupMenuItem(
          value: 'ru',
          checked: effectiveTag == 'ru',
          child: Text(l10n.languageRussian),
        ),
      ],
    );
  }
}
