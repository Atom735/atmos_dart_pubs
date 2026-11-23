# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 2.1.1

- В README добавлены сетап машины и результаты бенчмарков

## 2.1.0

- Добавлены `read/writeBool`, `read/writeBytes`, `read/writeBytesSized`
- Добавлены `read/writeFourCC`, `read/writeUuid` (+ тип `Uuid`), `read/writeCString`
- Добавлен `EpochUnit`, расширены `read/writeDateTime`; добавлены `read/writeDuration`
- Добавлены `read/writeUleb128` и `read/writeSleb128` в стиле DWARF/WASM

## 2.0.2

- Добавлен набор бенчмарков (`dart run benchmark/run.dart`)
- Добавлен `BinaryWriter.withCapacity` для заранее выделенного буфера
- Ускорены hot-path: inline на скалярах, прямой доступ к буферу для `uint8`/`int8`, batched packed `writeSize`
- Переиспользование scratch `ByteData` для bit-cast `float32` (помогает `float16` / `bfloat16`)

## 2.0.1

- Поднят SDK до `>=3.0.0 <4.0.0` (Dart 3 / Flutter 3.16.9)
- Обновлены метаданные пакета (`description`, `topics`, ссылки монорепо)
- Причёсаны README, LICENSE и `.gitignore`; `example/` исключён из analyze пакета
- Исправлены замечания `full_2` (trailing commas, якоря dartdoc-шаблонов)

## 2.0.0

- добавлены утилиты конвертации IEEE 754 `float16` и `bfloat16`, а также хелперы реинтерпретации битов `float32`
- расширены `BinaryReader`/`BinaryWriter`: `read/writeFloat16`, `read/writeBFloat16`, методы для списков и короткие алиасы (`rI/rU/rF*`, `wI/wU/wF*`)
- добавлены конструкторы `BinaryReader` для `TypedData`, `ByteData` и `ByteBuffer`
- переработан и дополнен двуязычный DartDoc (сначала EN, затем RU), очищены templates/macros и обновлены публичные экспорты/документация

## 1.0.1

- обновлена документация: разделены секции ENG и RU (ENG сверху)
- версия в README обновлена до 1.0.1

## 1.0.0

- исправлено zigzag encode/decode для веба (`>>` вместо `>>>`)
- исправлены `ByteData.view` и typed list views для буферов с `offsetInBytes`
- исправлены все `writeList*AV` с учётом offset буфера при создании view
- обновлена документация с подробным описанием zigzag
- добавлен раздел об ограничениях веб-совместимости

## 0.17.0

- добавлен endian в reader/writer

## 0.16.6

- исправлено чтение list views из offsetted view

## 0.16.5

- исправлен пропущенный символ в коде

## 0.16.4

- новый алгоритм упаковки

## 0.16.3

- чтение/запись списков sizes (packed uint):
    `readListSize`/`writeListSize`
- чтение/запись packed integer и списков:
    `readPackedInt`/`writePackedInt`/`readListPackedInt`/`writeListPackedInt`

## 0.16.2

- исправлен README

## 0.16.1

- зависимость Dart SDK: 2.16.1
- публикация на pub.dev

## 0.0.1

- Первый релиз.
