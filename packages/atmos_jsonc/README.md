# atmos_jsonc

Streaming **JSONC** decoder for Dart by [Atom735](https://github.com/Atom735).

- `//` and `/* */` comments
- Trailing commas in objects / arrays
- **Single-pass** parse (no intermediate stripped JSON string)
- `Converter` / chunked sink (`utf8.decoder.fuse(jsonc.decoder)`)
- Path-aware **reviver** (full key/index stack)
- Pull **binder** API to build Dart classes without intermediate `Map`s
- **`JsoncUtf8Decoder`** — parse UTF-8 bytes without a full document `String`

## Install

```yaml
dependencies:
  atmos_jsonc: ^0.1.0
```

## Examples

Runnable demos live in [`example/example.dart`](example/example.dart):

```bash
cd packages/atmos_jsonc
dart run example/example.dart
```

Covers tree decode, path reviver → class, `jsoncBind`, SAX `jsoncVisit`, and
`stripJsonc`.

## Quick start

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

### Path reviver (full stack)

Unlike `dart:convert`, the reviver receives the **entire** path
(`user` / `0` / `name`), not only the immediate key:

```dart
final value = jsoncDecode(
  source,
  reviver: (path, value) {
    if (path.endsWith('user') && value is Map) {
      return User.fromJson(value); // still gets a Map for that node
    }
    return value;
  },
);
```

Fast tree decode (no reviver) stays on the direct parser path. With a reviver,
decoding goes through visitor events + bottom-up rebuild.

### Bind classes without Maps

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

### UTF-8 bytes (`JsoncUtf8Decoder`)

Prefer when the source is already bytes (files, sockets) — skips a full
`utf8.decode` → `String` of the document:

```dart
final value = jsoncDecodeUtf8(file.readAsBytesSync());

// or stream:
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

### Prefer decode over strip

`stripJsonc` + `jsonDecode` works, but allocates a second full string. Prefer
`jsoncDecode` / `JsoncDecoder` for large files.

## Benchmarks

From package root:

```bash
dart run benchmark/run.dart      # time vs JsonDecoder
dart run benchmark/memory.dart   # RSS delta (one process per scenario)
```

### Machine

| Item | Value |
|------|-------|
| OS | Windows 10 Pro 10.0.19045 |
| CPU | AMD Ryzen 7 5800H (8 cores / 16 threads) |
| RAM | 39.4 GB |
| Flutter | 3.16.9 |
| Dart | 3.2.6 (stable, `windows_x64`) |

### Time (`benchmark/run.dart`, ~5k objects)

Lower is better (`benchmark_harness` RunTime).

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

Notes:

- Single-pass `jsoncDecode` beats native `jsonDecode` on this workload.
- From bytes, `jsoncDecodeUtf8` beats `utf8.decode` + `jsoncDecode`.
- Identity path-reviver stays on the same tree path.
- `jsoncBind` can win when mapping into slim Dart classes (skips `Map` graph).

### Memory (`benchmark/memory.dart`, 80k objects)

RSS delta while keeping the decoded graph alive (isolated child process per row).

| Scenario | Source | Time | RSS Δ |
|----------|--------|------|-------|
| jsonDecode plain | 4.63 MiB | 67 ms | 33.9 MiB |
| jsoncDecode plain | 4.63 MiB | 55 ms | 33.8 MiB |
| strip+jsonDecode plain | 4.63 MiB | 115 ms | 38.9 MiB |
| utf8.decode+jsoncDecode plain | 4.63 MiB | 60 ms | 38.4 MiB |
| **jsoncDecodeUtf8 plain** | 4.63 MiB | **52 ms** | **33.8 MiB** |
| **jsoncDecodeUtf8 JSONC** | 6.00 MiB | **56 ms** | **33.8 MiB** |

## License

MIT — see [LICENSE](LICENSE).
