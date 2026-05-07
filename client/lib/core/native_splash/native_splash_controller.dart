import 'package:flutter_native_splash/flutter_native_splash.dart';

/// Tiny wrapper around `FlutterNativeSplash.remove`.
///
/// Call [removeNow] from your first feature page (or whenever the
/// initial route is ready to be shown) to hide the native splash.
/// Wrap the call in a try/catch is not needed — the package itself
/// is a no-op on subsequent calls.
class NativeSplashController {
  NativeSplashController({SplashRemover? splashRemover})
    : _splashRemover = splashRemover ?? FlutterNativeSplash.remove;

  final SplashRemover _splashRemover;
  bool _removed = false;

  void removeNow() {
    if (_removed) return;
    _removed = true;
    try {
      _splashRemover();
    } catch (_) {
      // Splash already removed or never activated — ignore.
    }
  }
}

typedef SplashRemover = void Function();
