part of '__all.dart';

/// Коллекция зарегистрированных parsers для разбора значений.
///
/// {@category Core}
/// {@category Parser}
@immutable
class AtmosParsers extends MapBase<Type, AtmosParser> {
  @literal
  const AtmosParsers(this.proxy);

  final Map<Type, AtmosParser> proxy;

  @override
  AtmosParser? operator [](Object? key) {
    if (key is! Type) return null;
    final parser = proxy[key];
    if (parser != null) return parser;
    for (final e in proxy.values) {
      if (e._listType == key) {
        return e._listParser;
      }
    }
    return null;
  }

  @override
  void operator []=(Type key, AtmosParser value) {
    throw UnimplementedError();
  }

  @override
  void clear() {
    throw UnimplementedError();
  }

  @override
  Iterable<Type> get keys => proxy.keys;

  @override
  AtmosParser? remove(Object? key) {
    throw UnimplementedError();
  }
}
