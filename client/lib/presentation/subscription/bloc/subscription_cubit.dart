import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/logger/logger.dart';
import 'package:transaction_screen/core/types/failure.dart';
import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/subscription/entity/subscription_entity.dart';
import 'package:transaction_screen/domain/subscription/repository/i_subscription_repository.dart';
import 'package:transaction_screen/domain/subscription/usecase/refresh_subscription_usecase.dart';
import 'package:transaction_screen/domain/subscription/usecase/restore_purchases_usecase.dart';
import 'package:transaction_screen/presentation/auth/bloc/auth_cubit.dart';

part 'subscription_cubit.freezed.dart';
part 'subscription_state.dart';

/// Owns subscription state and the RevenueCat ↔ Supabase bridge.
///
/// On every signed-in session, calls `bindUser(userId)` so RevenueCat
/// purchases / restores attach to the correct app_user_id, then refreshes
/// the subscription. On sign-out, calls `unbindUser`.
///
/// Call [bootstrap] once after the parent [AuthCubit] is created — it
/// subscribes to auth state and drives the RC identity lifecycle.
@lazySingleton
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._authCubit, this._repository, this._refresh, this._restore)
    : super(const SubscriptionState());

  final AuthCubit _authCubit;
  final ISubscriptionRepository _repository;
  final RefreshSubscriptionUseCase _refresh;
  final RestorePurchasesUseCase _restore;

  StreamSubscription<AuthState>? _authSubscription;
  String? _boundUserId;

  Future<void> bootstrap() async {
    await _authSubscription?.cancel();
    _authSubscription = _authCubit.stream.listen(_onAuthChanged);
    final initial = _authCubit.state;
    if (initial.isResolved) {
      unawaited(_onAuthChanged(initial));
    }
  }

  Future<void> _onAuthChanged(AuthState authState) async {
    if (isClosed) return;
    final session = authState.session;
    if (authState.isAuthenticated && session != null) {
      if (_boundUserId == session.userId) return;
      _boundUserId = session.userId;
      await _repository.bindUser(session.userId);
      unawaited(refresh(silent: true));
    } else if (!authState.isAuthenticated && _boundUserId != null) {
      _boundUserId = null;
      await _repository.unbindUser();
      emit(const SubscriptionState());
    }
  }

  Future<void> refresh({bool silent = false}) async {
    if (state.isSyncing) return;
    if (!silent) emit(state.copyWith(isSyncing: true, failure: null));
    final result = await _refresh();
    if (isClosed) return;
    switch (result) {
      case Success<SubscriptionEntity>(value: final sub):
        emit(
          state.copyWith(
            status: SubscriptionStatus.synced,
            subscription: sub,
            isSyncing: false,
            failure: null,
          ),
        );
      case FailureResult<SubscriptionEntity>(failure: final failure):
        logger.e('SubscriptionCubit.refresh failed: ${failure.code}');
        emit(state.copyWith(status: SubscriptionStatus.error, isSyncing: false, failure: failure));
    }
  }

  Future<void> restorePurchases() async {
    if (state.isRestoring || state.isSyncing) return;
    emit(state.copyWith(isRestoring: true, failure: null));
    final result = await _restore();
    if (isClosed) return;
    switch (result) {
      case Success<SubscriptionEntity>(value: final sub):
        emit(
          state.copyWith(
            status: SubscriptionStatus.synced,
            subscription: sub,
            isRestoring: false,
            failure: null,
          ),
        );
      case FailureResult<SubscriptionEntity>(failure: final failure):
        logger.e('SubscriptionCubit.restorePurchases failed: ${failure.code}');
        emit(
          state.copyWith(status: SubscriptionStatus.error, isRestoring: false, failure: failure),
        );
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
