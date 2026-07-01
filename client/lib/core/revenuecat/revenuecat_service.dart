import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:transaction_screen/core/config/app_config.dart';

/// Thin abstraction so the app never talks to `Purchases` directly.
///
/// Two implementations live below: a no-op default and a real one that
/// proxies to `purchases_flutter`. DI selects between them based on the
/// `ENABLE_REVENUECAT` config flag (see `RevenueCatModule`).
abstract class RevenueCatService {
  Future<Offerings?> getOfferings();
  Future<CustomerInfo?> getCustomerInfo();
  Future<CustomerInfo?> restorePurchases();
  Future<LogInResult?> logIn(String appUserId);
  Future<CustomerInfo?> logOut();
}

class NoopRevenueCatService implements RevenueCatService {
  const NoopRevenueCatService();

  @override
  Future<Offerings?> getOfferings() async => null;

  @override
  Future<CustomerInfo?> getCustomerInfo() async => null;

  @override
  Future<CustomerInfo?> restorePurchases() async => null;

  @override
  Future<LogInResult?> logIn(String appUserId) async => null;

  @override
  Future<CustomerInfo?> logOut() async => null;
}

class PurchasesFlutterRevenueCatService implements RevenueCatService {
  const PurchasesFlutterRevenueCatService();

  @override
  Future<Offerings?> getOfferings() => Purchases.getOfferings();

  @override
  Future<CustomerInfo?> getCustomerInfo() => Purchases.getCustomerInfo();

  @override
  Future<CustomerInfo?> restorePurchases() => Purchases.restorePurchases();

  @override
  Future<LogInResult?> logIn(String appUserId) => Purchases.logIn(appUserId);

  @override
  Future<CustomerInfo?> logOut() => Purchases.logOut();
}

@module
abstract class RevenueCatModule {
  @lazySingleton
  RevenueCatService provideRevenueCatService() {
    if (!AppConfig.instance.enableRevenueCat) {
      return const NoopRevenueCatService();
    }
    return const PurchasesFlutterRevenueCatService();
  }
}
