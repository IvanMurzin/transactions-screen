part of 'subscription_cubit.dart';

enum SubscriptionStatus { initial, syncing, synced, error }

@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const SubscriptionState._();

  const factory SubscriptionState({
    @Default(SubscriptionStatus.initial) SubscriptionStatus status,
    SubscriptionEntity? subscription,
    @Default(false) bool isSyncing,
    @Default(false) bool isRestoring,
    Failure? failure,
  }) = _SubscriptionState;

  bool get isPro => subscription?.isPro ?? false;
  bool get isBusy => isSyncing || isRestoring;
}
