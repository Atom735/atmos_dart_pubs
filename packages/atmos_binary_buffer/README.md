# atmos_binary_buffer

Binary reader/writer utilities for Dart by [Atom735](https://github.com/Atom735).

Supports compact integer packing, typed list views, and IEEE 754 helpers
(`float16`, `bfloat16`, `float32`, `float64`).

## Install

```yaml
dependencies:
  atmos_binary_buffer: ^2.1.1
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
- `bool`, raw/sized `bytes`, FourCC, NUL-terminated C strings
- `Uuid` (16 bytes), `DateTime` / `Duration` via `EpochUnit`
- ULEB128 / SLEB128 (DWARF / WASM style)
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

### Reference machine

| Item | Value |
|------|-------|
| OS | Windows 10 Pro 10.0.19045 |
| CPU | AMD Ryzen 7 5800H (8 cores / 16 threads) |
| RAM | 39.4 GB |
| Flutter | 3.16.9 |
| Dart | 3.2.6 (stable, `windows_x64`) |

Results below were measured on this machine with `package:benchmark_harness` (`dart run benchmark/run.dart`). Lower is better; numbers are approximate RunTime per benchmark iteration.

### Results (atmos_binary_buffer 2.1.1)

| Benchmark | RunTime |
|-----------|---------|
| write Int32 ×50000 (prealloc) | ~2130 µs |
| read Int32 ×50000 | ~645 µs |
| write Float64 ×50000 (prealloc) | ~6140 µs |
| read Float64 ×50000 | ~3400 µs |
| writeSize packed ×50000 (prealloc) | ~1230 µs |
| readSize packed ×50000 | ~1150 µs |
| writeListInt32 callback ×4096 | ~287 µs |
| writeListInt32AV ×4096 | ~121 µs |
| readListInt32 callback ×4096 | ~297 µs |
| readListInt32AV ×4096 | ~0.28 µs |
| float16 encode+decode ×50000 | ~7850 µs |
| bfloat16 encode+decode ×50000 | ~6190 µs |
| toBytes after 5000 int32 | ~221 µs |
| takeBytes after 5000 int32 | ~223 µs |

Notes:

- Prefer `*AV` list APIs for dense numeric data (read AV is ~1000× faster than callback lists here).
- Use `BinaryWriter.withCapacity` when the output size is roughly known.
- Re-run locally after changes; absolute times depend on CPU load and power mode.

## Docs

API documentation on pub.dev includes bilingual DartDoc (EN first, then RU) and shared `{@template}` / `{@macro}` topics for packing and reader/writer methods.

## License

MIT — see [LICENSE](LICENSE).
