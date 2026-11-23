part of '../__all.dart';

/// Parser ожидаемых [String] (Строковых) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserString extends AtmosParser<String> {
  const AtmosParserString() : super(name: 'string');

  @override
  String? parse(Object? input) {
    if (input is String?) return input;

    return input.toString();
  }

  @override
  Object? serialize(String? input) {
    return input;
  }
}
