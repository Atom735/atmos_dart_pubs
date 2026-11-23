part of '../__all.dart';

/// Parser ожидаемых [DateTime] (Даты и времени) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserDateTime extends AtmosParser<DateTime> {
  const AtmosParserDateTime() : super(name: 'dateTime');

  @override
  DateTime? parse(Object? input) {
    if (input is DateTime?) return input;
    if (input is String) {
      input = input.trim();
      if (input.isEmpty) return null;
      return DateTime.tryParse(input);
    }

    if (input is int) {
      return DateTime.fromMillisecondsSinceEpoch(input * 1000);
    }

    errorUnparsed();
    return null;
  }

  @override
  Object? serialize(DateTime? input) {
    return input?.toIso8601String();
  }
}
