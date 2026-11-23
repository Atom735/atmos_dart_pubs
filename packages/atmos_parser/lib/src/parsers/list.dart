part of '../__all.dart';

/// Parser списков.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserList<T> extends AtmosParser<List<T>> {
  const AtmosParserList(this.parser) : super(name: 'list');
  final AtmosParser<T> parser;

  /// Проверка объекта что он может являться списком.
  static bool checkKeys(Map object) {
    return object.keys.every(checkKey);
  }

  /// Проверка значения ключа что он может отобразить список.
  static bool checkKey(Object? key) {
    if (key is String) {
      return key.isNotEmpty && key.isDigits;
    }
    if (key is int) return true;
    return false;
  }

  @override
  List<T>? parse(Object? input) {
    if (input is List<T>?) return input;
    if (input is Iterable) {
      final ctx = AtmosParserContext.get;
      T? mapper(Object? input) {
        return AtmosParserContext(
          input: input,
          name: '#NUM',
          parent: ctx,
        ).zoned(parser.parseFromZone);
      }

      return input.map(mapper).whereType<T>().toList();
    }
    if (input is Map) {
      if (input.keys.every(checkKey)) {
        return parse(input.values);
      }
    }
    errorUnparsed();
    return null;
  }

  @override
  Object? serialize(List<T>? input) {
    return input?.map(parser.serialize).toList();
  }
}
