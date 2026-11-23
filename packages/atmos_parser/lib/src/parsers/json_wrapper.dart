part of '../__all.dart';

/// Parser ожидаемых [T] (Любых) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserFromJsonWrapper<T> extends AtmosParser<T> {
  const AtmosParserFromJsonWrapper(this.fromJsonFunc, [this.toJsonFunc])
      : super(name: 'fromJsonWrapper');
  final T Function(Map<String, dynamic> input) fromJsonFunc;
  final Object? Function(T? input)? toJsonFunc;

  @override
  T? parse(Object? input) {
    if (input == null) return null;
    return fromJsonFunc(input as Map<String, dynamic>);
  }

  @override
  Object? serialize(T? input) {
    return toJsonFunc?.call(input);
  }
}

/// Parser ожидаемых [T] (JSON Safe) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserJSON<T> extends AtmosParser<T> {
  const AtmosParserJSON(this.proxy) : super(name: 'json_safe');

  final AtmosParser<T> proxy;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    if (input is Iterable && input.isEmpty) {
      return null;
    }
    if (input is String && input.isEmpty) return null;
    if (input is List<int>) {
      if (input.isEmpty) return null;
      input = const Utf8Decoder(allowMalformed: true)
          .fuse(const JsonDecoder())
          .convert(input);
    }
    return proxy.startParse(input);
  }

  @override
  Object? serialize(T? input) {
    return proxy.serialize(input);
  }
}
