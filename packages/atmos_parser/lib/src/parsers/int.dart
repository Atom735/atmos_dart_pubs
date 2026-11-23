part of '../__all.dart';

/// Parser ожидаемых [int] (Целочисленных) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserInt extends AtmosParser<int> {
  const AtmosParserInt([this.radix]) : super(name: 'int');

  /// Ожидаемая разрядность числа.
  final int? radix;

  @override
  int? parse(Object? input) {
    if (input is int?) return input;
    return AtmosParserNum(radix).parse(input)?.toInt();
  }

  @override
  Object? serialize(int? input) {
    return input;
  }
}
