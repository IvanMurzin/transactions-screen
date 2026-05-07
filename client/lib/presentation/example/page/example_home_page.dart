import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:template_app/core/routing/app_routes.dart';
import 'package:template_app/core_ui/components/ds_app_bar.dart';
import 'package:template_app/core_ui/components/ds_button.dart';
import 'package:template_app/core_ui/components/ds_card.dart';
import 'package:template_app/core_ui/theme/ds_theme.dart';
import 'package:template_app/l10n/app_localizations.dart';

/// First-feature example page.
///
/// Use this as a reference for layering: a page widget belongs in
/// `presentation/<feature>/page/`, reads strings via `AppLocalizations`,
/// and composes UI from `core_ui` components — never from raw Material
/// widgets unless you really need to.
class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;

    return Scaffold(
      appBar: DSAppBar(title: l10n.appTitle),
      body: Padding(
        padding: EdgeInsets.all(spacing.s16),
        child: DSCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.exampleHomeTitle, style: typography.h2),
              SizedBox(height: spacing.s8),
              Text(l10n.exampleHomeBody, style: typography.body),
              SizedBox(height: spacing.s16),
              DSButton(
                label: l10n.exampleHomeOpenDesignSystem,
                fullWidth: true,
                onPressed: () => context.go(AppRoutes.designSystem),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
