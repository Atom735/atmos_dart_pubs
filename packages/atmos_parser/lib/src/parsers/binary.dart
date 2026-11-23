part of '../__all.dart';

/// Parser ожидаемых [Uint8List] (Бинарных) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserBinary extends AtmosParser<Uint8List> {
  const AtmosParserBinary() : super(name: 'binary');

  @override
  Uint8List? parse(Object? input) {
    if (input is Uint8List) return input;

    if (input is List<int>) {
      return Uint8List.fromList(input);
    }

    final settings = AtmosParserSettings.get;
    if (settings.ignoreValueMissmatch || settings.ignoreUnhandledValues) {
      return null;
    } else {
      errorUnparsed();
    }

    return null;
  }

  @override
  Object? serialize(Uint8List? input) {
    return input;
  }
}
