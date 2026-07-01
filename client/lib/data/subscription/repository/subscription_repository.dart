import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/logger/logger.dart';
import 'package:transaction_screen/core/revenuecat/revenuecat_service.dart';
import 'package:transaction_screen/core/supabase/supabase_failure_mapper.dart';
import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/data/subscription/data_source/supabase_subscription_data_source.dart';
import 'package:transaction_screen/domain/profile/repository/i_profile_repository.dart';
import 'package:transaction_screen/domain/subscription/entity/subscription_entity.dart';
import 'package:transaction_screen/domain/subscription/repository/i_subscription_repository.dart';

/// RevenueCat-bound subscription repository.
///
/// Source of truth for `plan` is `profiles.plan` in the backend — the
/// RevenueCat SDK on device only initiates purchases / restores. Every
/// state read goes through `IProfileRepository.getProfile()` after a
/// backend refresh, so the client never trusts the local SDK alone.
@LazySingleton(as: ISubscriptionRepository)
class SubscriptionRepository implements ISubscriptionRepository {
  SubscriptionRepository(this._dataSource, this._profileRepository, this._revenueCat);

  final SupabaseSubscriptionDataSource _dataSource;
  final IProfileRepository _profileRepository;
  final RevenueCatService _revenueCat;

  @override
  Future<Result<SubscriptionEntity>> refresh() async {
    try {
      await _dataSource.refreshFromRevenueCat();
    } catch (error) {
      logger.e('SubscriptionRepository.refresh failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to refresh subscription'),
      );
    }
    return _readFromProfile();
  }

  @override
  Future<Result<SubscriptionEntity>> restorePurchases() async {
    try {
      await _revenueCat.restorePurchases();
    } catch (error) {
      logger.e('SubscriptionRepository.restorePurchases failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to restore purchases'),
      );
    }
    return refresh();
  }

  @override
  Future<void> bindUser(String userId) async {
    try {
      await _revenueCat.logIn(userId);
    } catch (error, stackTrace) {
      logger.e('SubscriptionRepository.bindUser failed', error: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> unbindUser() async {
    try {
      await _revenueCat.logOut();
    } catch (error, stackTrace) {
      logger.e('SubscriptionRepository.unbindUser failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<Result<SubscriptionEntity>> _readFromProfile() async {
    final profileResult = await _profileRepository.getProfile();
    return switch (profileResult) {
      Success(value: final profile) => Success(
        SubscriptionEntity(
          plan: profile.plan,
          source: 'revenuecat',
          revenuecatAppUserId: profile.revenuecatAppUserId,
          updatedAt: profile.updatedAt,
        ),
      ),
      FailureResult(failure: final failure) => FailureResult(failure),
    };
  }
}
