part of '../__all.dart';

class AtmosParserJsonObject extends AtmosParserMap<String, Object?> {
  const AtmosParserJsonObject()
      : super(
          const AtmosParserString(),
          const AtmosParserIgnore(),
        );
}

/// Parser ожидаемой карты (JS Объекта) [Map] данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserMap<K, V> extends AtmosParser<Map<K, V>> {
  const AtmosParserMap(this.keyParser, this.valueParser) : super(name: 'map');

  /// Parser ключей карты.
  final AtmosParser<K> keyParser;

  /// Parser значений карты.
  final AtmosParser<V> valueParser;

  static Map<K, V> clearMap<K, V>(Map<K?, V?> value) {
    final entries = value.entries
        .where((e) => e.key is K && e.value is V)
        .map((e) => MapEntry(e.key as K, e.value as V));
    return Map.fromEntries(entries);
  }

  @override
  Map<K, V>? parse(Object? input) {
    if (input is Map<K, V>?) return input;

    final ctx = AtmosParserContext.get;
    K? mapperKey(Object? input) {
      return AtmosParserContext(
        input: input,
        name: '#KEY',
        parent: ctx,
      ).zoned(keyParser.parseFromZone);
    }

    V? mapperValue(Object? key, Object? input) {
      return AtmosParserContext(
        input: input,
        name: '#VALUE[$key]',
        parent: ctx,
      ).zoned(valueParser.parseFromZone);
    }

    if (input is Map) {
      try {
        final raw = <K?, V?>{
          for (final e in input.entries)
            mapperKey(e.key): mapperValue(e.key, ctx[e.key]),
        };
        return clearMap(raw);
      } on Object {}
    } else if (input is List) {
      try {
        final raw = <K?, V?>{
          for (var i = 0; i < input.length; i++)
            mapperKey(i): mapperValue(i, input[i]),
        };
        return clearMap(raw);
      } on Object {}
    }
    errorUnparsed();
    return null;
  }

  @override
  Object? serialize(Map<K, V>? input) {
    if (input == null) return null;
    return {
      for (final e in input.entries)
        keyParser.serialize(e.key): valueParser.serialize(e.value),
    };
  }
}
