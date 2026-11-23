part of '../__all.dart';

/// Parser ожидаемых [Object] (Любых) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserIgnore extends AtmosParser<Object> {
  const AtmosParserIgnore() : super(name: 'ignore');

  @override
  Object? parse(Object? input) {
    return input;
  }

  @override
  Object? serialize(Object? input) {
    return input;
  }
}
