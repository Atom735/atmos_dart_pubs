part of '../__all.dart';

/// Parser ожидаемой карты (JS Объекта) [Map] данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserSelector<V> extends AtmosParser<V> {
  const AtmosParserSelector(
    this.key, [
    this.parser,
  ]) : super(name: 'selector');

  final String key;

  /// Parser значений карты.
  final AtmosParser<V>? parser;

  @override
  V? parse(Object? input) {
    if (input is V?) return input;
    return v(key, parser);
  }

  @override
  Object? serialize(V? input) {
    if (input == null) return null;
    return {
      key: (parser ?? getParser<V>()).serialize(input),
    };
  }
}
