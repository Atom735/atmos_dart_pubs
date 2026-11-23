part of '__all.dart';

/// Контекст парсинга.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserContext {
  AtmosParserContext({
    required this.name,
    required this.input,
    this.parent,
  }) {
    parent?.children.add(this);
  }

  /// Ключ/название разбираемого объекта.
  String name;

  /// Разбираемый объект на этом уровне.
  Object? input;

  bool get isMap => input is Map;
  Map<Object?, Object?> get inputMap => input! as Map<Object?, Object?>;
  bool get isIterable => input is Iterable;
  Iterable<Object?> get inputList => input! as Iterable<Object?>;

  /// Контекст разбираемого объекта сверху/выше/до.
  AtmosParserContext? parent;

  /// Дочерние контексты/ниже/потомки.
  final children = HashSet<AtmosParserContext>.identity();

  /// Ключи в разбираемом объекте.
  late final Set<String> keys = isMap
      ? HashSet.from(inputMap.keys.map((e) => e.toString()))
      : const <String>{};

  /// Ключи в разбираемом объекте (без учета регистра и других форматов).
  late final HashMap<String, String> keysFlat = HashMap.fromEntries(
    keys.map(
      (e) => MapEntry(
        e.replaceAll(AtmosParserSettings._caseSplitter, '').toLowerCase(),
        e,
      ),
    ),
  );

  /// Использованные ключи разбираемого объекта.
  final keysUsed = HashSet<String>.identity();

  /// Промахи по ключам.
  final keysMissmatch = HashSet<String>.identity();

  /// Неиспользованные ключи разбираемого объекта.
  Set<String> get keysUnused => keys.difference(keysUsed);

  /// Путь к разбираемому объекту по сегментам.
  List<String> get pathSegmented {
    final str = [name];
    var parent = this.parent;
    while (parent != null) {
      str.add(parent.name);
      parent = parent.parent;
    }
    return str.reversed.toList();
  }

  /// Путь к разбираемому объекту.
  String get path {
    return pathSegmented.join(' / ');
  }

  /// Получить контекст parsers из зоны.
  static AtmosParserContext get get {
    return getN!;
  }

  /// Получить nullable контекст parsers из зоны.
  static AtmosParserContext? get getN {
    return Zone.current[AtmosParserContext] as AtmosParserContext?;
  }

  /// Выполнить функцию в зоне с данным контекстом.
  T zoned<T>(T Function() action) {
    return Zone.current.fork(
      zoneValues: {AtmosParserContext: this},
    ).run(action);
  }

  /// Получить значение по ключу из разбираемого объекта
  /// который обязан быть [Map].
  Object? operator [](String key) {
    final m = inputMap;

    /// Проверяем прямое совпадение ключа.
    if (keys.contains(key)) {
      keysUsed.add(key);
      return m[key];
    }

    final options = AtmosParserSettings.get;

    /// Проверяем прямое совпадение ключа в нижнем регистре.
    if (options.useKeyUncased) {
      final keyLower = key.toLowerCase();
      final a = keys.where((e) => e.toLowerCase() == keyLower).firstOrNull;
      if (a != null) {
        keysUsed.add(a);
        keysMissmatch.add(key);
        return m[a];
      }
      if (options.useKeyOtherCases) {
        final words = key
            .split(AtmosParserSettings._caseSplitter)
            .map((e) => e.toLowerCase())
            .toList();
        final cases = {
          words.join('_'),
          words.join('-'),
          words.join(' '),
        };
        final a =
            keys.where((e) => cases.contains(e.toLowerCase())).firstOrNull;
        if (a != null) {
          keysUsed.add(a);
          keysMissmatch.add(key);
          return m[a];
        }
      }
    }
    if (options.useKeyExtended) {
      final keyFlat =
          key.replaceAll(AtmosParserSettings._caseSplitter, '').toLowerCase();
      final a = keysFlat[keyFlat];
      if (a != null) {
        keysUsed.add(a);
        keysMissmatch.add(key);
        return m[a];
      }
    }
    return null;
  }
}
