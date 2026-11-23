# atmos_jsonc

English: [README.md](README.md).

Потоковый **JSONC**-декодер для Dart от [Atom735](https://github.com/Atom735).

- комментарии `//` и `/* */`
- Trailing commas в объектах / массивах
- **Однопроходный** parse (без промежуточной stripped JSON-строки)
- `Converter` / chunked sink (`utf8.decoder.fuse(jsonc.decoder)`)
- Path-aware **reviver** (полный стек ключей/индексов)
- Pull **binder** API для сборки Dart-классов без промежуточных `Map`
- **`JsoncUtf8Decoder`** — разбор UTF-8 байт без полной `String` документа

## Установка

```yaml
dependencies:
  atmos_jsonc: ^0.1.0
```

## Примеры

Runnable-демо в [`example/example.dart`](example/example.dart):

```bash
cd packages/atmos_jsonc
dart run example/example.dart
```

Покрывает tree decode, path reviver → class, `jsoncBind`, SAX `jsoncVisit` и
`stripJsonc`.

## Быстрый старт

```dart
import 'package:atmos_jsonc/atmos_jsonc.dart';

void main() {
  final value = jsoncDecode('''
  {
    // comment
    "a": 1,
    "b": [2, 3,],
  }
  ''');
  print(value); // {a: 1, b: [2, 3]}
}
```

### Path reviver (полный стек)

В отличие от `dart:convert`, reviver получает **весь** путь
(`user` / `0` / `name`), а не только ближайший ключ:

```dart
final value = jsoncDecode(
  source,
  reviver: (path, value) {
    if (path.endsWith('user') && value is Map) {
      return User.fromJson(value); // для узла всё ещё приходит Map
    }
    return value;
  },
);
```

Быстрый tree decode (без reviver) остаётся на прямом пути парсера. С reviver
декодирование идёт через visitor-события и bottom-up rebuild.

### Bind классов без Map

```dart
class Point {
  Point(this.x, this.y);
  final int x;
  final int y;
}

class PointBinder implements JsoncBinder<Point> {
  const PointBinder();

  @override
  Point fromJsonc(JsoncReader r) {
    r.expectObject();
    var x = 0;
    var y = 0;
    while (r.nextField()) {
      switch (r.key) {
        case 'x':
          x = r.readInt();
        case 'y':
          y = r.readInt();
        default:
          r.skip();
      }
      r.endField();
    }
    return Point(x, y);
  }
}

final point = jsoncBind('{"x":1,"y":2}', const PointBinder());
```

### Visitor (SAX)

```dart
jsoncVisit(source, MyVisitor());
```

### UTF-8 байты (`JsoncUtf8Decoder`)

Предпочтительнее, когда источник уже байты (файлы, сокеты) — без полного
`utf8.decode` → `String` документа:

```dart
final value = jsoncDecodeUtf8(file.readAsBytesSync());

// или поток:
final value = await file.openRead().transform(jsoncUtf8.decoder).first;
```

### Streaming chunks (String)

```dart
import 'dart:convert';
import 'dart:io';

import 'package:atmos_jsonc/atmos_jsonc.dart';

Future<void> load(File file) async {
  final decoded = await file
      .openRead()
      .transform(utf8.decoder)
      .transform(jsonc.decoder)
      .first;
  print(decoded);
}
```

### Лучше decode, чем strip

`stripJsonc` + `jsonDecode` работает, но выделяет вторую полную строку. Для
больших файлов предпочитайте `jsoncDecode` / `JsoncDecoder`.

## Бенчмарки

Из корня пакета:

```bash
dart run benchmark/run.dart      # время vs JsonDecoder
dart run benchmark/memory.dart   # дельта RSS (отдельный процесс на сценарий)
```

### Машина

| Параметр | Значение |
|----------|----------|
| OS | Windows 10 Pro 10.0.19045 |
| CPU | AMD Ryzen 7 5800H (8 cores / 16 threads) |
| RAM | 39.4 GB |
| Flutter | 3.16.9 |
| Dart | 3.2.6 (stable, `windows_x64`) |

### Время (`benchmark/run.dart`, ~5k объектов)

Меньше — лучше (`benchmark_harness` RunTime).

| Benchmark | RunTime |
|-----------|---------|
| jsonDecode plain | ~25.7 ms |
| **jsoncDecode plain** | **~21.0 ms** |
| strip+jsonDecode plain | ~58.0 ms |
| **jsoncDecode JSONC** | **~24.1 ms** |
| strip+jsonDecode JSONC | ~61.1 ms |
| jsoncDecode+identityReviver plain | ~25.7 ms |
| **jsoncBind Item list plain** | **~20.2 ms** |
| utf8.decode+jsoncDecode plain | ~26.0 ms |
| **jsoncDecodeUtf8 plain** | **~21.5 ms** |
| **jsoncDecodeUtf8 JSONC** | **~22.3 ms** |

Замечания:

- Однопроходный `jsoncDecode` обгоняет native `jsonDecode` на этой нагрузке.
- Из байт `jsoncDecodeUtf8` быстрее, чем `utf8.decode` + `jsoncDecode`.
- Identity path-reviver остаётся на том же tree-пути.
- `jsoncBind` может выигрывать при маппинге в тонкие Dart-классы (без графа `Map`).

### Память (`benchmark/memory.dart`, 80k объектов)

Дельта RSS при удержании decoded-графа (изолированный child process на строку).

| Scenario | Source | Time | RSS Δ |
|----------|--------|------|-------|
| jsonDecode plain | 4.63 MiB | 67 ms | 33.9 MiB |
| jsoncDecode plain | 4.63 MiB | 55 ms | 33.8 MiB |
| strip+jsonDecode plain | 4.63 MiB | 115 ms | 38.9 MiB |
| utf8.decode+jsoncDecode plain | 4.63 MiB | 60 ms | 38.4 MiB |
| **jsoncDecodeUtf8 plain** | 4.63 MiB | **52 ms** | **33.8 MiB** |
| **jsoncDecodeUtf8 JSONC** | 6.00 MiB | **56 ms** | **33.8 MiB** |

## Лицензия

MIT — см. [LICENSE](LICENSE).
