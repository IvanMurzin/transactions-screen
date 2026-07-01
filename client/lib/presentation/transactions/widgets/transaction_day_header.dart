import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:transaction_screen/l10n/app_localizations.dart';

class TransactionDayHeader extends StatelessWidget {
  const TransactionDayHeader({required this.day, super.key});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        _label(context, day),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _label(BuildContext context, DateTime day) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return l10n.transactionsToday;
    if (diff == 1) return l10n.transactionsYesterday;

    final locale = Localizations.localeOf(context).toString();
    return DateFormat.MMMEd(locale).format(day);
  }
}
