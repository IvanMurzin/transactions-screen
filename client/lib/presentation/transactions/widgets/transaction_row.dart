import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:transaction_screen/core_ui/theme/status_colors.dart';
import 'package:transaction_screen/domain/transaction/entity/transaction_entity.dart';
import 'package:transaction_screen/presentation/transactions/widgets/transaction_status_style.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({required this.transaction, super.key});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusStyle = TransactionStatusStyle.of(context, transaction.status);
    final isDeclined = transaction.status == TransactionStatus.declined;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _LeadingIcon(type: transaction.type, tint: statusStyle.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _merchantLabel(transaction.merchantName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      TimeOfDay.fromDateTime(transaction.date).format(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('·', style: theme.textTheme.bodySmall),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        statusStyle.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusStyle.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatAmount(transaction),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: _amountColor(context, transaction),
              decoration: isDeclined ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  static String _merchantLabel(String name) {
    if (name.isEmpty) return 'Unknown merchant';
    final isAddress = name.startsWith('0x') && name.length > 14;
    if (isAddress) {
      return '${name.substring(0, 6)}…${name.substring(name.length - 4)}';
    }
    return name;
  }

  static String _formatAmount(TransactionEntity tx) {
    final formatted = NumberFormat('#,##0.00').format(tx.amount.abs());
    final sign = tx.isCredit ? '+' : '−';
    final currency = tx.currency.isEmpty ? '' : ' ${tx.currency}';
    return '$sign$formatted$currency';
  }

  static Color _amountColor(BuildContext context, TransactionEntity tx) {
    final theme = Theme.of(context);
    if (tx.status == TransactionStatus.declined) {
      return theme.colorScheme.onSurfaceVariant;
    }
    if (tx.isCredit) {
      return context.statusColors.success;
    }
    return theme.colorScheme.onSurface;
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.type, required this.tint});

  final TransactionType type;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(_iconFor(type), size: 20, color: tint),
    );
  }

  static IconData _iconFor(TransactionType type) {
    switch (type) {
      case TransactionType.cardPayment:
        return Icons.credit_card;
      case TransactionType.inboundCrypto:
        return Icons.south_west;
      case TransactionType.outboundCrypto:
        return Icons.north_east;
      case TransactionType.unknown:
        return Icons.receipt_long;
    }
  }
}
