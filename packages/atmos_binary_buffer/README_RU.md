# atmos_binary_buffer

English: [README.md](README.md).

Утилиты binary reader/writer для Dart от [Atom735](https://github.com/Atom735).

Поддерживают компактную упаковку целых, typed list views и хелперы IEEE 754
(`float16`, `bfloat16`, `float32`, `float64`).

## Установка

```yaml
dependencies:
  atmos_binary_buffer: ^2.1.1
```

## Импорт

```dart
import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
```

## Возможности

- `BinaryReader` / `BinaryWriter` для примитивов и строк
- Компактная упаковка size / int (`readSize` / `writeSize`, zigzag packed ints)
- Методы списков и выровненные typed-view методы (`*AV`)
- Чтение/запись `float16` и `bfloat16` (включая списки)
- Хелперы реинтерпретации битов `float32`
- `bool`, raw/sized `bytes`, FourCC, NUL-terminated C strings
- `Uuid` (16 байт), `DateTime` / `Duration` через `EpochUnit`
- ULEB128 / SLEB128 (стиль DWARF / WASM)
- Расширения: `typedData.reader` / `.writer`, `byteBuffer.reader` / `.writer`

## Быстрый пример

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

Больше сценариев — в [`example/example.dart`](example/example.dart) (packed sizes, zigzag, endian, typed views).

Если размер выхода примерно известен, предпочитайте `BinaryWriter.withCapacity(...)`, чтобы меньше grow/copy.

## Бенчмарки

```bash
cd packages/atmos_binary_buffer
dart run benchmark/run.dart
```

### Эталонная машина

| Параметр | Значение |
|----------|----------|
| OS | Windows 10 Pro 10.0.19045 |
| CPU | AMD Ryzen 7 5800H (8 cores / 16 threads) |
| RAM | 39.4 GB |
| Flutter | 3.16.9 |
| Dart | 3.2.6 (stable, `windows_x64`) |

Результаты ниже сняты на этой машине с `package:benchmark_harness` (`dart run benchmark/run.dart`). Меньше — лучше; числа приблизительные RunTime на итерацию бенчмарка.

### Результаты (atmos_binary_buffer 2.1.1)

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

Замечания:

- Для плотных числовых данных предпочитайте `*AV` (read AV здесь ~1000× быстрее callback-списков).
- Используйте `BinaryWriter.withCapacity`, когда размер выхода примерно известен.
- Перезамеряйте локально после изменений; абсолютные времена зависят от нагрузки CPU и power mode.

## Docs

API-документация на pub.dev включает двуязычный DartDoc (сначала EN, затем RU) и общие `{@template}` / `{@macro}` для packing и методов reader/writer.

## Лицензия

MIT — см. [LICENSE](LICENSE).
