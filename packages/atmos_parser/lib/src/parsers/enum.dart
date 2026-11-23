part of '../__all.dart';

typedef AtmosParserEnumCC<T extends Enum>
    = AtmosParserEnumCustomNameIgnoringCaseWithCustomIndex<T>;

@Deprecated('Deprecated with [AtmosParserEnumCC]')
abstract class AtmosParserEnumName<T extends Enum> extends AtmosParser<T> {
  @Deprecated('Deprecated with [AtmosParserEnumCC]')
  const AtmosParserEnumName(this.values);

  final List<T> values;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    final s = const AtmosParserString().parse(input);
    if (s == null) return null;
    return values.where((e) => e.name == s).firstOrNull;
  }

  @override
  Object? serialize(T? input) {
    if (input == null) return null;
    return input.name;
  }
}

@Deprecated('Deprecated with [AtmosParserEnumCC]')
abstract class AtmosParserEnumCustom<T extends Enum> extends AtmosParser<T> {
  @Deprecated('Deprecated with [AtmosParserEnumCC]')
  const AtmosParserEnumCustom(this.values, this.nameMapper);

  final List<T> values;
  final String Function(T) nameMapper;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    final s = const AtmosParserString().parse(input);
    if (s == null) return null;
    return values.where((e) => nameMapper(e) == s).firstOrNull;
  }

  @override
  Object? serialize(T? input) {
    if (input == null) return null;
    return nameMapper(input);
  }
}

class AtmosParserEnumCustomNameIgnoringCaseWithCustomIndex<T extends Enum>
    extends AtmosParserEnumCustomNameIgnoringCaseWithCustomIndexBase<T> {
  const AtmosParserEnumCustomNameIgnoringCaseWithCustomIndex(
    super.value, {
    this.nameMapperFunc = $nameMapperDefaultFunc,
    this.indexMapperFunc = $indexMapperDefaultFunc,
    super.toIndex = false,
  });

  static String $nameMapperDefaultFunc(Enum value) => value.name;
  static int $indexMapperDefaultFunc(Enum value) => value.index;

  final String Function(T) nameMapperFunc;
  final int Function(T) indexMapperFunc;

  @override
  String nameMapper(T value) => nameMapperFunc(value);
  @override
  int indexMapper(T value) => indexMapperFunc(value);
}

abstract class AtmosParserEnumCustomNameIgnoringCaseWithCustomIndexBase<
    T extends Enum> extends AtmosParserEnumBase<T> {
  const AtmosParserEnumCustomNameIgnoringCaseWithCustomIndexBase(
    super.values, {
    this.toIndex = false,
  });

  final bool toIndex;

  String nameMapper(T value);
  int indexMapper(T value);

  static final $nameMapperCache = Expando<Map<String, Enum>>(
    'AtmosParserEnumCustomNameIgnoringCaseWithCustomIndexBase',
  );
  static final $indexMapperCache = Expando<Map<int, Enum>>(
    'AtmosParserEnumCustomNameIgnoringCaseWithCustomIndexBase',
  );

  Map<String, T> $nameMapCached() => ($nameMapperCache[this] ??= <String, T>{
        for (final value in values) nameMapper(value).toLowerCase(): value,
      }) as Map<String, T>;

  Map<int, T> $indexMapCached() => ($indexMapperCache[this] ??= <int, T>{
        for (final value in values) indexMapper(value): value,
      }) as Map<int, T>;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    try {
      final i = const AtmosParserInt().parse(input);
      final map = $indexMapCached();
      if (i != null && map.containsKey(i)) {
        return map[i];
      }
      // ignore: empty_catches
    } on Object {}
    final s = const AtmosParserString().parse(input)?.toLowerCase();
    if (s == null) return null;
    return $nameMapCached()[s];
  }

  @override
  Object? serialize(T? input) {
    if (input == null) return null;
    if (toIndex) return indexMapper(input);
    return nameMapper(input);
  }
}

abstract class AtmosParserEnumBase<T extends Enum> extends AtmosParser<T> {
  const AtmosParserEnumBase(this.values);

  final List<T> values;
}

@Deprecated('Deprecated with [AtmosParserEnumCC]')
class AtmosParserEnumNameIgnoringCase<T extends Enum> extends AtmosParser<T> {
  @Deprecated('Deprecated with [AtmosParserEnumCC]')
  const AtmosParserEnumNameIgnoringCase(this.values);

  final List<T> values;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    final s = const AtmosParserString().parse(input)?.toLowerCase();
    if (s == null) return null;
    return values.where((e) => e.name.toLowerCase() == s).firstOrNull;
  }

  @override
  Object? serialize(T? input) {
    if (input == null) return null;
    return input.name;
  }
}

@Deprecated('Deprecated with [AtmosParserEnumCC] with `toIndex = true`')
abstract class AtmosParserEnumIndex<T extends Enum> extends AtmosParser<T> {
  @Deprecated('Deprecated with [AtmosParserEnumCC] with `toIndex = true`')
  const AtmosParserEnumIndex(this.values);

  final List<T> values;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    final s = const AtmosParserInt().parse(input);
    if (s == null) return null;
    if (s >= 0 && s < values.length) return values[s];
    return null;
  }

  @override
  Object? serialize(T? input) {
    if (input == null) return null;
    return input.index;
  }
}

@Deprecated('Deprecated with [AtmosParserEnumCC]')
abstract interface class AtmosEnumString implements Enum {
  String get value;
}

@Deprecated('Deprecated with [AtmosParserEnumCC]')
abstract class AtmosParserEnumString<T extends AtmosEnumString>
    extends AtmosParser<T> {
  @Deprecated('Deprecated with [AtmosParserEnumCC]')
  const AtmosParserEnumString(this.values);

  final List<T> values;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    final s = const AtmosParserString().parse(input);
    if (s == null) return null;
    return values.where((e) => e.value == s).firstOrNull;
  }

  @override
  Object? serialize(T? input) {
    if (input == null) return null;
    return input.value;
  }
}

@Deprecated('Deprecated with [AtmosParserEnumCC]')
abstract interface class AtmosEnumInt implements Enum {
  int get value;
}

@Deprecated('Deprecated with [AtmosParserEnumCC]')
abstract class AtmosParserEnumInt<T extends AtmosEnumInt>
    extends AtmosParser<T> {
  @Deprecated('Deprecated with [AtmosParserEnumCC]')
  const AtmosParserEnumInt(this.values);

  final List<T> values;

  @override
  T? parse(Object? input) {
    if (input is T?) return input;
    final s = const AtmosParserInt().parse(input);
    if (s == null) return null;
    return values.where((e) => e.value == s).firstOrNull;
  }

  @override
  Object? serialize(T? input) {
    if (input == null) return null;
    return input.value;
  }
}
