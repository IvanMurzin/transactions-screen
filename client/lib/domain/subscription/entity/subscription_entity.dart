import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_entity.freezed.dart';

/// Snapshot of the current user's subscription, derived from
/// `profiles.plan` after a RevenueCat webhook or `/api/revenuecat/refresh`
/// call has applied the latest entitlement state.
///
/// `source` records who set the current value: `revenuecat` for events
/// that came through the webhook or refresh endpoint, `local` for the
/// default `free` baseline before the first sync.
@freezed
abstract class SubscriptionEntity with _$SubscriptionEntity {
  const SubscriptionEntity._();

  const factory SubscriptionEntity({
    @Default('free') String plan,
    @Default('local') String source,
    String? revenuecatAppUserId,
    DateTime? updatedAt,
  }) = _SubscriptionEntity;

  bool get isPro => plan == 'pro';
}
