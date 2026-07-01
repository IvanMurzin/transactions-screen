import 'package:flutter/material.dart';

import 'package:transaction_screen/core_ui/theme/status_colors.dart';
import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';
import 'package:transaction_screen/l10n/app_localizations.dart';

class TransactionStatusStyle {
  const TransactionStatusStyle({required this.color, required this.label});

  final Color color;
  final String label;

  factory TransactionStatusStyle.of(BuildContext context, TransactionStatus status) {
    final colors = context.statusColors;
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case TransactionStatus.pending:
        return TransactionStatusStyle(color: colors.muted, label: l10n.transactionStatusPending);
      case TransactionStatus.settled:
        return TransactionStatusStyle(color: colors.success, label: l10n.transactionStatusSettled);
      case TransactionStatus.declined:
        return TransactionStatusStyle(color: colors.error, label: l10n.transactionStatusDeclined);
      case TransactionStatus.reversed:
        return TransactionStatusStyle(color: colors.muted, label: l10n.transactionStatusReversed);
      case TransactionStatus.unknown:
        return TransactionStatusStyle(color: colors.muted, label: '—');
    }
  }
}
