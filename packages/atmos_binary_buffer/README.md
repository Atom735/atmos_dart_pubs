# atmos_binary_buffer

Binary reader/writer utilities for Dart by [Atom735](https://github.com/Atom735).

Supports compact integer packing, typed list views, and IEEE 754 helpers
(`float16`, `bfloat16`, `float32`, `float64`).

## Install

```yaml
dependencies:
  atmos_binary_buffer: ^2.0.2
```

## Import

```dart
import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
```

## Highlights

- `BinaryReader` / `BinaryWriter` for primitives and strings
- Compact size / int packing (`readSize` / `writeSize`, zigzag packed ints)
- Typed list methods and aligned typed-view methods (`*AV`)
- `float16` and `bfloat16` read/write (including list helpers)
- `float32` bit reinterpretation helpers
- Extensions: `typedData.reader` / `.writer`, `byteBuffer.reader` / `.writer`

## Quick example

```dart
import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

void main() {
  final writer = BinaryWriter()
    ..writeInt32(42)
    ..writeFloat16(0.1)
    ..writeBFloat16(3.14159)
    ..writeListPackedInt([1, -1, 127, -128]);

  final reader = writer.toBytes().reader;

  final a = reader.readInt32();
  final f16 = reader.readFloat16();
  final bf16 = reader.readBFloat16();
  final packed = reader.readListPackedInt();

  // ignore: avoid_print
  print('$a, $f16, $bf16, $packed');
}
```

See [`example/example.dart`](example/example.dart) for more scenarios (packed sizes, zigzag, endian, typed views).

When the output size is roughly known, prefer `BinaryWriter.withCapacity(...)` to avoid grow/copy churn.

## Benchmarks

```bash
cd packages/atmos_binary_buffer
dart run benchmark/run.dart
```

## Docs

API documentation on pub.dev includes bilingual DartDoc (EN first, then RU) and shared `{@template}` / `{@macro}` topics for packing and reader/writer methods.

## License

MIT — see [LICENSE](LICENSE).
