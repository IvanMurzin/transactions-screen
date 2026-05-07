# Theming

`ThemeData` is built once per brightness in `app_theme.dart`:

```dart
final ThemeData lightTheme = _buildTheme(_lightColors, Brightness.light);
final ThemeData darkTheme  = _buildTheme(_darkColors,  Brightness.dark);
```

`_buildTheme`:

1. Wires `colorScheme` from `DSColors`.
2. Sets `scaffoldBackgroundColor`, `appBarTheme`, `dialogTheme`,
   `cardTheme` from tokens.
3. Registers the token extensions on `extensions:` so widgets can
   read them via `context.<dsX>`.

`MaterialApp.router` in `app.dart` toggles between them via
`ThemeModeCubit`. The cubit persists the choice via
`ThemeModeStorage`.

## Adding light/dark parity

Every field in `_lightColors` must also exist in `_darkColors`. The
DS reviewer enforces this. Dark is a separate palette — don't think
of it as "light with inverted colors".

## Per-platform tweaks

If iOS and Android need different visuals, branch inside the
component using `Theme.of(context).platform`, not by forking widgets.
