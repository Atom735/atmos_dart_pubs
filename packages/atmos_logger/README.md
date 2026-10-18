# atmos_logger

Lightweight **composable** logger for Dart and Flutter by [Atom735](https://github.com/Atom735).

Build a pipeline by wrapping loggers: print / console / file / filter / buffer / broadcast / named scope.

## Install

```yaml
dependencies:
  atmos_logger: ^0.18.0
```

## Quick start

```dart
import 'package:atmos_logger/atmos_logger.dart';

void main() {
  final log = LoggerNamed(
    'app',
    LoggerFilter(
      (data) => data.level >= LogLevel.info,
      const LoggerPrint(),
    ),
  );

  log.info('Server started');
  log.warn('Config missing', 'using defaults');
  log.debug('skipped by filter');
}
```

### File sink (VM / `dart:io` only)

```dart
import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';

final log = LoggerNamed(
  'app',
  LoggerFile(File('app.log'), const LoggerConsole()),
);
```

## Imports

| Import | Contents |
|--------|----------|
| `package:atmos_logger/atmos_logger.dart` | Core API + console/print sinks (VM/web via conditional exports) |
| `package:atmos_logger/atmos_logger_io.dart` | Everything above + `LoggerFile` |

## Log levels

From `LogLevel` (lower = more verbose):

| Constant | Typical use |
|----------|-------------|
| `trace` | Very detailed flow / async breadcrumbs |
| `debug` | Major operations start/stop |
| `info` | Rare lifecycle events (config loaded, plugin started) |
| `warn` | Unexpected but recoverable situations |
| `error` | Needs developer attention |
| `fatal` | Process cannot continue |

Also: `all` (0) and `off` (7) for filters.

## Composition

Each logger optionally wraps a `subLogger` and forwards after its own work:

- `LoggerPrint` — `print(...)`
- `LoggerConsole` — stdout with ANSI (VM) / web console
- `LoggerFile` — append to a file (`atmos_logger_io.dart`)
- `LoggerFilter` — keep messages matching a predicate
- `LoggerNamed` — prefix / nest logger name
- `LoggerBuffer` / `LoggerBroadcast` / `LoggerCallback` — buffering, fan-out, hooks
- `LoggerVoid` — no-op (useful as a terminal or stub)

## License

MIT — see [LICENSE](LICENSE).
