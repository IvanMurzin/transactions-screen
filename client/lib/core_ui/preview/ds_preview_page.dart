import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:template_app/core_ui/components/ds_app_bar.dart';
import 'package:template_app/core_ui/components/ds_button.dart';
import 'package:template_app/core_ui/components/ds_card.dart';
import 'package:template_app/core_ui/components/ds_dialog.dart';
import 'package:template_app/core_ui/components/ds_loader.dart';
import 'package:template_app/core_ui/theme/ds_theme.dart';
import 'package:template_app/core_ui/theme/theme_mode_cubit.dart';
import 'package:template_app/l10n/app_localizations.dart';

/// Storybook-style page that exercises every reusable design-system
/// component in light and dark modes.
///
/// Add a new section here for every component you ship — agents and
/// developers use this page to discover what already exists before
/// reinventing it. Keep the content nutrition-free: lorem ipsum / generic
/// labels only, never product copy.
class DSPreviewPage extends StatelessWidget {
  const DSPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    final colors = context.dsColors;

    return Scaffold(
      appBar: DSAppBar(
        title: l10n.designSystemPreviewTitle,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: spacing.s12),
            child: const _ThemeSwitcher(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s16, spacing.s16, spacing.s32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'Typography',
              child: DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Heading 1', style: typography.h1),
                    SizedBox(height: spacing.s8),
                    Text('Heading 2', style: typography.h2),
                    SizedBox(height: spacing.s8),
                    Text('Heading 3', style: typography.h3),
                    SizedBox(height: spacing.s8),
                    Text('Body — primary text', style: typography.body),
                    SizedBox(height: spacing.s8),
                    Text(
                      'Caption — secondary text',
                      style: typography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            _Section(
              title: 'Buttons',
              child: Wrap(
                spacing: spacing.s12,
                runSpacing: spacing.s12,
                children: [
                  DSButton(label: 'Primary', onPressed: () {}),
                  DSButton(
                    label: 'Secondary',
                    variant: DSButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  DSButton(label: 'Danger', variant: DSButtonVariant.danger, onPressed: () {}),
                  const DSButton(label: 'Disabled'),
                  const DSButton(label: 'Loading', isLoading: true),
                ],
              ),
            ),
            SizedBox(height: spacing.s24),
            _Section(
              title: 'Card',
              child: DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card title', style: typography.h3),
                    SizedBox(height: spacing.s8),
                    Text(
                      'Cards group related content. Replace this body with your own '
                      'feature copy when assembling product screens.',
                      style: typography.body.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.s24),
            _Section(
              title: 'Dialog',
              child: DSButton(
                label: 'Show dialog',
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => DSDialog(
                      title: 'Confirm action',
                      content: const Text(
                        'This is a sample dialog. Wire it to real handlers in features.',
                      ),
                      primaryLabel: 'Confirm',
                      onPrimary: () => Navigator.of(context).pop(),
                      secondaryLabel: 'Cancel',
                      onSecondary: () => Navigator.of(context).pop(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: spacing.s24),
            _Section(title: 'Loader', child: const DSLoader()),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dsSpacing;
    final typography = context.dsTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typography.h2),
        SizedBox(height: spacing.s12),
        child,
      ],
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  const _ThemeSwitcher();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder: (context, mode) {
        final brightness = mode == ThemeMode.system
            ? Theme.of(context).brightness
            : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
        final isDark = brightness == Brightness.dark;
        return Switch(
          value: isDark,
          onChanged: (value) =>
              context.read<ThemeModeCubit>().set(value ? ThemeMode.dark : ThemeMode.light),
        );
      },
    );
  }
}
