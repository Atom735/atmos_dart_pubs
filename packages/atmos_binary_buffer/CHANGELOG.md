# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 2.1.1

- Document reference machine setup and benchmark results in README

## 2.1.0

- Add `read/writeBool`, `read/writeBytes`, `read/writeBytesSized`
- Add `read/writeFourCC`, `read/writeUuid` (+ `Uuid` type), `read/writeCString`
- Add `EpochUnit` and extend `read/writeDateTime`; add `read/writeDuration`
- Add DWARF/WASM-style `read/writeUleb128` and `read/writeSleb128`

## 2.0.2

- Add `benchmark/` suite (`dart run benchmark/run.dart`)
- Add `BinaryWriter.withCapacity` for preallocated output buffers
- Speed up hot paths: inline pragmas on scalars, direct `uint8`/`int8` buffer access, batched packed `writeSize`
- Reuse a scratch `ByteData` for `float32` bit-cast (helps `float16` / `bfloat16`)

## 2.0.1

- Raise SDK constraint to `>=3.0.0 <4.0.0` (Dart 3 / Flutter 3.16.9 toolchain)
- Refresh package metadata (`description`, `topics`, monorepo links)
- Polish README, LICENSE, and `.gitignore`; exclude `example/` from package analyze
- Fix `full_2` analyzer nits (trailing commas, dartdoc template anchors)

## 2.0.0

- add IEEE 754 `float16` and `bfloat16` conversion utilities, plus `float32` bit reinterpretation helpers
- extend `BinaryReader`/`BinaryWriter` with `read/writeFloat16`, `read/writeBFloat16`, list methods, and short aliases (`rI/rU/rF*`, `wI/wU/wF*`)
- add `BinaryReader` constructors for `TypedData`, `ByteData`, and `ByteBuffer`
- reorganize and complete bilingual DartDoc (EN first, RU second), clean up templates/macros, and refresh public exports/docs

## 1.0.1

- update documentation: split into ENG and RU sections (ENG on top)
- update README version to 1.0.1

## 1.0.0

- fix zigzag encoding/decoding for web compatibility (use `>>` instead of `>>>`)
- fix `ByteData.view` and typed list views to properly handle buffers with `offsetInBytes`
- fix all `writeList*AV` methods to account for buffer offset when creating views
- update documentation with detailed zigzag encoding description
- add web compatibility limitations section to documentation

## 0.17.0

- added endian to reader/writer

## 0.16.6

- fix troubles with read lists views from offsetted view

## 0.16.5

- fix missed symbol in code

## 0.16.4

- set new pack algorithm

## 0.16.3

- add read/write for list of sizes (packed uint) values
    `readListSize`/`writeListSize`

- add read/write for packed integer value and list of thats values
    `readPackedInt`/`writePackedInt`/`readListPackedInt`/`writeListPackedInt`

## 0.16.2

- fixed README

## 0.16.1

- Set last Dart SDK (2.16.1) dependecy
- Publish on pub.dev

## 0.0.1

- Initial version.
