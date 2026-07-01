import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/supabase/supabase_constants.dart';
import 'package:transaction_screen/core/supabase/supabase_edge_functions.dart';

@lazySingleton
class SupabaseSubscriptionDataSource {
  SupabaseSubscriptionDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  /// Triggers `/api/revenuecat/refresh` — the backend re-reads entitlements
  /// from the RevenueCat REST API and writes the resulting plan back to
  /// `profiles.plan` via `api_apply_revenuecat_event`.
  Future<void> refreshFromRevenueCat() async {
    await _edgeFunctions.invokeVoid(SupabaseApiRoutes.revenuecatRefresh);
  }
}
