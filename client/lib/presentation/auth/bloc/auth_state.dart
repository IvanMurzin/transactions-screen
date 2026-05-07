part of 'auth_cubit.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    AuthSessionEntity? session,
    @Default(false) bool isSigningOut,
    @Default(false) bool isDeletingAccount,
    String? failureCode,
    String? failureMessage,
  }) = _AuthState;

  bool get isAuthenticated => status == AuthStatus.authenticated && session != null;
  bool get isResolved => status != AuthStatus.initial;
  bool get isBusy => isSigningOut || isDeletingAccount;
}
