part of '../__all.dart';

/// Parser ожидаемых [bool] (Булевых) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserBool extends AtmosParser<bool> {
  const AtmosParserBool() : super(name: 'bool');

  @override
  bool? parse(Object? input) {
    if (input is bool?) return input;
    if (input is String) {
      final i = input.trim().toUpperCase();
      if ({'TRUE', 'T', 'YES', 'Y', '+', '1'}.contains(i)) {
        return true;
      } else if ({'FALSE', 'F', 'NO', 'N', '-', '0'}.contains(i)) {
        return false;
      }
    } else if (input is int) {
      return input != 0;
    } else if (input is double) {
      return input != 0.0;
    }
    errorUnparsed();
    return null;
  }

  @override
  Object? serialize(bool? input) {
    return input;
  }
}
