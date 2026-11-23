part of '__all.dart';

/// Общий интерфейс parsers.
///
/// {@category Core}
/// {@category Parser}
@immutable
abstract class AtmosParser<T> {
  @literal
  const AtmosParser({this.name = 'unknown'});

  /// Название parser.
  final String name;

  Type get _listType => List<T>;
  AtmosParserList<T> get _listParser => AtmosParserList(this);

  /// Список зарегистрированных parsers для разбора значений.
  AtmosParsers get deps => const AtmosParsers({});

  Logger? get logger => Zone.current[Logger];

  /// Зарегистрированные parsers.
  static const parsersDefault = AtmosParsers({
    num: AtmosParserNum(),
    List<num>: AtmosParserList(AtmosParserNum()),
    List<num?>: AtmosParserList(AtmosParserNum()),
    int: AtmosParserInt(),
    List<int>: AtmosParserList(AtmosParserInt()),
    List<int?>: AtmosParserList(AtmosParserInt()),
    double: AtmosParserDouble(),
    List<double>: AtmosParserList(AtmosParserDouble()),
    List<double?>: AtmosParserList(AtmosParserDouble()),
    bool: AtmosParserBool(),
    List<bool>: AtmosParserList(AtmosParserBool()),
    List<bool?>: AtmosParserList(AtmosParserBool()),
    String: AtmosParserString(),
    List<String>: AtmosParserList(AtmosParserString()),
    List<String?>: AtmosParserList(AtmosParserString()),
    Uri: AtmosParserUri(),
    List<Uri>: AtmosParserList(AtmosParserUri()),
    List<Uri?>: AtmosParserList(AtmosParserUri()),
    DateTime: AtmosParserDateTime(),
    List<DateTime>: AtmosParserList(AtmosParserDateTime()),
    List<DateTime?>: AtmosParserList(AtmosParserDateTime()),
  });

  /// Получить зарегистрированный parser.
  AtmosParser<K> getParser<K extends Object?>() {
    final parser = deps[K] ?? parsersDefault[K];
    if (parser == null) {
      throw StateError('Parser для типа $K не зарегистрирован');
    }
    return parser as AtmosParser<K>;
  }

  T? startParseFromJsonString(
    String? input, {
    Uri? uri,
    Logger? logger,
  }) {
    if (input == null) return null;
    if (input.isEmpty) return null;
    return startParse(
      const JsonDecoder().convert(input),
      uri: uri,
      logger: logger,
    );
  }

  /// Начать разбор данных.
  T? startParse(
    Object? input, {
    Uri? uri,
    Logger? logger,
  }) {
    return Zone.current.fork(
      zoneValues: {
        Uri: uri,
        Logger: logger,
        AtmosParserContext: AtmosParserContext(
          input: input,
          name: '#ROOT',
        ),
      },
    ).run(parseFromZone);
  }

  /// Карта проигнорированных ключей.
  static final keysIgnored = <String, Set<String>>{};

  /// Разбор значения используя этот parser и данные контекста из зоны.
  @protected
  T? parseFromZone() {
    final ctx = AtmosParserContext.get;
    final out = parse(ctx.input);
    final settings = AtmosParserSettings.get;
    if (!settings.ignoreKeyUnused) {
      if (ctx.keysUnused.isNotEmpty) {
        final path = ctx.path;
        final keys = '${ctx.keysUnused}';
        final set = keysIgnored[path] ??= {};
        if (set.add(keys)) {
          logger?.fine('Проигнорированы ключи: в [${ctx.path}]\n'
              ' ==> ${ctx.keysUnused}');
        }
      }
    }
    return out;
  }

  /// Сообщение что не удалось разобрать значение.
  @protected
  void errorUnparsed([String? message]) {
    final ctx = AtmosParserContext.get;
    logger?.warning(
      'Не удалось разобрать значение типа [$T] в [${ctx.path}].\n ==> $message',
    );
  }

  @protected
  T? parse(Object? input);

  /// Разбор объекта находящегося по ключу [key].
  @protected
  V? v<V extends Object?>([String? key, AtmosParser<V>? parser]) {
    parser ??= getParser();
    if (key == null) {
      return parser.parseFromZone();
    }
    final ctx = AtmosParserContext.get;
    return AtmosParserContext(
      input: ctx[key],
      name: key,
      parent: ctx,
    ).zoned(parser.parseFromZone);
  }

  ///   Игнорирование ключа [key].
  @protected
  V? ignore<V extends Object?>([String? key, AtmosParser<V>? parser]) {
    if (key == null) return null;
    final ctx = AtmosParserContext.get;
    return ctx[key] as V?;
  }

  /// Разбор [List] значения находящегося по ключу [key].
  @protected
  List<V>? list<V extends Object?>([String? key, AtmosParser<V>? parser]) {
    return v<List<V>>(
      key,
      AtmosParserList(
        parser ?? getParser<V>(),
      ),
    );
  }

  /// Разбор [Map] значения находящегося по ключу [key].
  @protected
  Map<K, V>? map<K extends Object?, V extends Object?>([
    String? key,
    AtmosParser<V>? parser,
  ]) {
    return v<Map<K, V>>(
      key,
      AtmosParserMap(
        getParser<K>(),
        parser ?? getParser<V>(),
      ),
    );
  }

  String? startSerializeToJsonString(T? input) {
    if (input == null) return null;
    return const JsonEncoder().convert(startSerialize(input));
  }

  Object? startSerialize(T? input) {
    return serialize(input);
  }

  Object? serialize(T? input);

  @protected
  Object? s<V extends Object?>(V? input, [AtmosParser<V>? parser]) {
    parser ??= getParser<V>();
    return parser.serialize(input);
  }

  @protected
  Object? sList<V extends Object?>(List<V>? input, [AtmosParser<V>? parser]) {
    return s<List<V>>(
      input,
      AtmosParserList(
        parser ?? getParser<V>(),
      ),
    );
  }

  @protected
  Object? sMap<K extends Object?, V extends Object?>(Map<K, V>? input,
      [AtmosParser<V>? parser]) {
    return s<Map<K, V>>(
      input,
      AtmosParserMap(
        getParser<K>(),
        parser ?? getParser<V>(),
      ),
    );
  }
}
