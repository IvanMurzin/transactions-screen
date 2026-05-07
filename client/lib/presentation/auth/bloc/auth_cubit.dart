import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:template_app/core/logger/logger.dart';
import 'package:template_app/core/session/unauthorized_notifier.dart';
import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/auth/entity/auth_session_entity.dart';
import 'package:template_app/domain/auth/usecase/delete_account_usecase.dart';
import 'package:template_app/domain/auth/usecase/sign_out_usecase.dart';
import 'package:template_app/domain/auth/usecase/watch_session_usecase.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

/// Owns the global session state.
///
/// Responsibilities:
///   - subscribe to the auth-session stream and keep [AuthState] in sync,
///   - sign out / delete account on user request,
///   - on a global 401 signal from [UnauthorizedNotifier], drop the
///     local session without calling Supabase signOut (the server-side
///     token is already invalid).
///
/// External integrations (RevenueCat identity, analytics user id, …)
/// listen to this cubit instead of being wired here, so the auth core
/// stays dependency-free.
@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._watchSession, this._signOut, this._deleteAccount, this._unauthorized)
    : super(const AuthState());

  final WatchSessionUseCase _watchSession;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;
  final UnauthorizedNotifier _unauthorized;

  StreamSubscription<AuthSessionEntity?>? _sessionSubscription;
  StreamSubscription<void>? _unauthorizedSubscription;

  Future<void> bootstrap() async {
    await _sessionSubscription?.cancel();
    await _unauthorizedSubscription?.cancel();
    emit(const AuthState());
    _sessionSubscription = _watchSession().listen(
      (session) => unawaited(_handleSessionChanged(session)),
      onError: (Object error, StackTrace stackTrace) {
        logger.e('Session stream failed', error: error, stackTrace: stackTrace);
        if (isClosed) return;
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            session: null,
            failureCode: 'session_stream_error',
            failureMessage: 'Unable to observe auth session',
          ),
        );
      },
    );
    _unauthorizedSubscription = _unauthorized.stream.listen((_) => unawaited(forceLocalSignOut()));
  }

  Future<void> _handleSessionChanged(AuthSessionEntity? session) async {
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          session: null,
          isSigningOut: false,
          isDeletingAccount: false,
          failureCode: null,
          failureMessage: null,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isSigningOut: false,
        isDeletingAccount: false,
        failureCode: null,
        failureMessage: null,
      ),
    );
  }

  Future<void> signOut() async {
    if (state.status == AuthStatus.unauthenticated || state.isBusy) return;

    emit(state.copyWith(isSigningOut: true, failureCode: null, failureMessage: null));

    final result = await _signOut();
    if (result case FailureResult<void>(failure: final failure)) {
      logger.e('AuthCubit.signOut failed: ${failure.code}');
      if (!isClosed) {
        emit(
          state.copyWith(
            isSigningOut: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
      }
    }
  }

  /// Drops the local session without calling Supabase signOut. Used when
  /// the backend has already rejected the current token (401) — calling
  /// `signOut` is pointless and the router takes care of the redirect.
  Future<void> forceLocalSignOut() async {
    if (isClosed || state.status != AuthStatus.authenticated) return;
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        session: null,
        isSigningOut: false,
        isDeletingAccount: false,
        failureCode: 'unauthorized',
        failureMessage: null,
      ),
    );
  }

  Future<void> deleteAccount() async {
    if (state.status == AuthStatus.unauthenticated || state.isBusy) return;

    emit(state.copyWith(isDeletingAccount: true, failureCode: null, failureMessage: null));

    final result = await _deleteAccount();
    if (result case FailureResult<void>(failure: final failure)) {
      logger.e('AuthCubit.deleteAccount failed: ${failure.code}');
      if (!isClosed) {
        emit(
          state.copyWith(
            isDeletingAccount: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    await _unauthorizedSubscription?.cancel();
    return super.close();
  }
}
