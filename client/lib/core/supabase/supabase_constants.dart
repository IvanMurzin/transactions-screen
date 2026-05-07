/// Edge Function endpoints exposed by the backend.
///
/// Add new entries as new Edge Functions land. Keep names short and
/// scoped under `api/`.
abstract final class SupabaseApiRoutes {
  static const health = 'api/health';

  // Profile / session
  static const me = 'api/me';
  static const profileUpdate = 'api/profile/update';
  static const deleteMyAccount = 'api/delete_my_account';

  // Subscriptions
  static const revenuecatRefresh = 'api/revenuecat/refresh';
}
