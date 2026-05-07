/// Available identity sources for sign-in.
///
/// `email` covers password and OTP flows. `google` and `apple` are exposed
/// only when [AppConfig.oauthRedirectUri] is configured.
enum AuthProvider { email, google, apple }
