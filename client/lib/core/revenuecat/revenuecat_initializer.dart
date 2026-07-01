import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:transaction_screen/core/config/app_config.dart';
import 'package:transaction_screen/core/logger/logger.dart';

/// Configures RevenueCat at app start. No-op when `ENABLE_REVENUECAT=false`.
///
/// When enabled, a placeholder API key (`REVENUECAT_API_KEY` from config)
/// is used. Replace it with a real key from RevenueCat dashboard before
/// shipping a paid build.
abstract final class RevenueCatInitializer {
  static Future<void> init() async {
    final config = AppConfig.instance;
    if (!config.enableRevenueCat) {
      logger.i('RevenueCat disabled via config — skipping init');
      return;
    }
    final key = config.revenueCatApiKey.trim();
    if (key.isEmpty || key.toLowerCase().contains('placeholder')) {
      logger.w(
        'RevenueCat enabled with a placeholder API key — purchases will not work. '
        'Set REVENUECAT_API_KEY in .config.<flavor>.json before shipping.',
      );
    }
    if (config.flavor == AppFlavor.dev) {
      await Purchases.setLogLevel(LogLevel.debug);
    }
    await Purchases.configure(PurchasesConfiguration(key));
    logger.i('revenuecat_configured');
  }
}
