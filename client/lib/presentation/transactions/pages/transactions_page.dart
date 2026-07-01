import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:transaction_screen/l10n/app_localizations.dart';
import 'package:transaction_screen/presentation/settings/widgets/language_menu_button.dart';
import 'package:transaction_screen/presentation/settings/widgets/theme_mode_menu_button.dart';
import 'package:transaction_screen/presentation/transactions/bloc/transactions_cubit.dart';
import 'package:transaction_screen/presentation/transactions/model/transaction_day_group.dart';
import 'package:transaction_screen/presentation/transactions/widgets/transaction_day_header.dart';
import 'package:transaction_screen/presentation/transactions/widgets/transaction_row.dart';
import 'package:transaction_screen/presentation/transactions/widgets/transactions_message_view.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  static const double _loadMoreThreshold = 400;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<TransactionsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionsTitle),
        actions: const [LanguageMenuButton(), ThemeModeMenuButton(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        child: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            switch (state.status) {
              case TransactionsStatus.initial:
              case TransactionsStatus.loading:
                if (state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
              case TransactionsStatus.error:
                if (state.items.isEmpty) {
                  return TransactionsMessageView(
                    icon: Icons.error_outline,
                    title: l10n.transactionsErrorTitle,
                    body: state.failure?.message,
                    onRetry: () => context.read<TransactionsCubit>().load(),
                    retryLabel: l10n.commonRetry,
                  );
                }
              case TransactionsStatus.loaded:
                if (state.isEmpty) {
                  return _EmptyState(l10n: l10n, onRefresh: _onRefresh);
                }
            }
            return _TransactionsList(
              groups: state.groups,
              isLoadingMore: state.isLoadingMore,
              controller: _scrollController,
              onRefresh: _onRefresh,
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh() => context.read<TransactionsCubit>().refresh();
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.onRefresh});

  final AppLocalizations l10n;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: TransactionsMessageView(
                icon: Icons.receipt_long_outlined,
                title: l10n.transactionsEmptyTitle,
                body: l10n.transactionsEmptyBody,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({
    required this.groups,
    required this.isLoadingMore,
    required this.controller,
    required this.onRefresh,
  });

  final List<TransactionDayGroup> groups;
  final bool isLoadingMore;
  final ScrollController controller;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          for (final group in groups) ...[
            SliverToBoxAdapter(child: TransactionDayHeader(day: group.day)),
            SliverList.builder(
              itemCount: group.items.length,
              itemBuilder: (context, index) => TransactionRow(transaction: group.items[index]),
            ),
          ],
          SliverToBoxAdapter(child: _ListFooter(isLoadingMore: isLoadingMore)),
        ],
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.isLoadingMore});

  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isLoadingMore ? 64 : 24,
      child: isLoadingMore ? const Center(child: CircularProgressIndicator.adaptive()) : null,
    );
  }
}
