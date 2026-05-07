# Logging

Single global logger from `core/logger/logger.dart`. Backed by the
`logger` package with a `PrettyPrinter`.

## Use

```dart
import 'package:<your_pkg>/core/logger/logger.dart';

logger.t('trace');
logger.d('debug');
logger.i('info');
logger.w('warning', error: e, stackTrace: s);
logger.e('error', error: e, stackTrace: s);
```

## Rules

- Never `print()`. There is no exception.
- Use structured payloads when handy: `logger.i({'event': 'x', 'foo': 1})`.
- Don't log secrets. Don't log full request bodies in production.
- Edge function side: use `console.log(JSON.stringify({...}))` so
  Supabase log search picks up structured fields.
