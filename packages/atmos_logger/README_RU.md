# atmos_logger

English: [README.md](README.md).

Лёгкий **композируемый** логгер для Dart и Flutter от [Atom735](https://github.com/Atom735).

Собирайте пайплайн обёртками: print / console / file / filter / buffer / broadcast / named scope.

## Установка

```yaml
dependencies:
  atmos_logger: ^0.18.0
```

## Быстрый старт

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

### Файловый sink (только VM / `dart:io`)

```dart
import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';

final log = LoggerNamed(
  'app',
  LoggerFile(File('app.log'), const LoggerConsole()),
);
```

## Импорты

| Импорт | Содержимое |
|--------|------------|
| `package:atmos_logger/atmos_logger.dart` | Ядро + console/print sinks (VM/web через conditional exports) |
| `package:atmos_logger/atmos_logger_io.dart` | Всё выше + `LoggerFile` |

## Уровни логов

Из `LogLevel` (меньше = подробнее):

| Константа | Типичное применение |
|-----------|---------------------|
| `trace` | Очень детальный поток / async breadcrumbs |
| `debug` | Старт/стоп крупных операций |
| `info` | Редкие lifecycle-события (конфиг загружен, плагин стартовал) |
| `warn` | Неожиданно, но восстанавливаемо |
| `error` | Нужно внимание разработчика |
| `fatal` | Процесс не может продолжаться |

Также: `all` (0) и `off` (7) для фильтров.

## Композиция

Каждый логгер опционально оборачивает `subLogger` и форвардит после своей работы:

- `LoggerPrint` — `print(...)`
- `LoggerConsole` — stdout с ANSI (VM) / web console
- `LoggerFile` — дописывает в файл (`atmos_logger_io.dart`)
- `LoggerFilter` — оставляет сообщения по предикату
- `LoggerNamed` — префикс / вложенное имя логгера
- `LoggerBuffer` / `LoggerBroadcast` / `LoggerCallback` — буфер, fan-out, хуки
- `LoggerVoid` — no-op (терминал или заглушка)

## Лицензия

MIT — см. [LICENSE](LICENSE).
