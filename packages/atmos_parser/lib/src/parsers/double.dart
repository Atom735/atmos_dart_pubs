part of '../__all.dart';

/// Parser ожидаемых [double] (Число с плавающей точкой) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserDouble extends AtmosParser<double> {
  const AtmosParserDouble() : super(name: 'double');

  @override
  double? parse(Object? input) {
    if (input is double?) return input;
    return const AtmosParserNum().parse(input)?.toDouble();
  }

  @override
  Object? serialize(double? input) {
    return input;
  }
}
