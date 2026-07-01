import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/subscription/entity/subscription_entity.dart';

abstract interface class ISubscriptionRepository {
  /// Asks the backend to re-pull entitlements from RevenueCat for the
  /// current user and returns the resulting subscription state. Use this
  /// after [restorePurchases] or when the UI suspects the local plan is
  /// stale (e.g. after returning from the App Store).
  Future<Result<SubscriptionEntity>> refresh();

  /// Forces RevenueCat to restore previously purchased entitlements on
  /// this device, then [refresh]es from the backend so `profiles.plan`
  /// reflects the new state.
  Future<Result<SubscriptionEntity>> restorePurchases();

  /// Logs the current Supabase user into RevenueCat so subsequent
  /// purchases / restores attach to the correct app_user_id. No-op when
  /// RevenueCat is disabled in [AppConfig].
  Future<void> bindUser(String userId);

  /// Logs the active RevenueCat user out — call on sign-out so the next
  /// user does not inherit the previous identity.
  Future<void> unbindUser();
}
