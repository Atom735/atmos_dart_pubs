part of '__all.dart';

/// Настройки парсера.
///
/// ```
/// twowords	flat case[18][19]
/// TWOWORDS	upper flat case[18]
/// twoWords	(lower) camelCase, dromedaryCase
/// TwoWords	(upper) CamelCase, PascalCase, StudlyCase[20]
/// two_words	snake case, pothole_case
/// TWO_WORDS	SCREAMING SNAKE CASE, MACRO_CASE, CONSTANT_CASE
/// Two_Words	Camel_Snake_Case[21]
/// two-words	kebab-case, dash-case, lisp-case
/// TWO-WORDS	TRAIN-CASE, COBOL-CASE, SCREAMING-KEBAB-CASE
/// Two-Words	Train-Case,[18] HTTP-Header-Case[21]
/// ```
/// {@category Core}
/// {@category Parser}
class AtmosParserSettings {
  const AtmosParserSettings.silent({
    this.ignoreUnhandledValues = true,
    this.ignoreValueMissmatch = true,
    this.ignoreKeyUnused = true,
    this.useKeyUncased = true,
    this.ignoreKeyUncased = true,
    this.useKeyOtherCases = true,
    this.ignoreKeyOtherCases = true,
    this.useKeyExtended = true,
    this.ignoreKeyExtended = true,
  });

  const AtmosParserSettings.verbose({
    this.ignoreUnhandledValues = false,
    this.ignoreValueMissmatch = false,
    this.ignoreKeyUnused = false,
    this.useKeyUncased = true,
    this.ignoreKeyUncased = false,
    this.useKeyOtherCases = true,
    this.ignoreKeyOtherCases = false,
    this.useKeyExtended = true,
    this.ignoreKeyExtended = false,
  });

  /// Получить контекст parsers из зоны.
  // ignore: prefer_constructors_over_static_methods
  static AtmosParserSettings get get {
    return getN ?? const AtmosParserSettings.silent();
  }

  /// Получить nullable контекст parsers из зоны.
  static AtmosParserSettings? get getN {
    return Zone.current[AtmosParserSettings] as AtmosParserSettings?;
  }

  /// Выполнить функцию в зоне с данным контекстом.
  T zoned<T>(T Function() action) {
    return Zone.current.fork(
      zoneValues: {AtmosParserSettings: this},
    ).run(action);
  }

  /// Разделитель слов для разбора ключа в разных форматах.
  static final _caseSplitter = RegExp(r'[\W_]|(?<=[a-z])(?=[A-Z])');

  /// Отключить промах по неизвестным типам значений.
  ///
  /// Иначе при несовпадении типов выбрасывается исключение.
  ///
  /// Прим: вместо ожидаемого типа числа пришла строка которую
  /// нельзя преобразовать в число.
  final bool ignoreUnhandledValues;

  /// Отключить промах по несовпадению типов значений.
  ///
  /// Прим: вместо ожидаемого типа строки пришло число.
  final bool ignoreValueMissmatch;

  /// Отключить предупреждение о неиспользованных ключах.
  final bool ignoreKeyUnused;

  /// Использовать промах включив в поиск ключи в нижнем регистре.
  /// Закрываем провал по `flat case`.
  ///
  /// `AbCd == abcd == aBcD`
  final bool useKeyUncased;

  /// Отключить промах по ключам в нижнем регистре.
  ///
  /// `AbCd == abcd == aBcD`
  final bool ignoreKeyUncased;

  /// Использовать промах включив в поиск ключи в других форматах.
  ///
  /// `AbCd == abcd == ab-cd == AB_CD`
  final bool useKeyOtherCases;

  /// Отключить промах по ключам в других форматах.
  ///
  /// `AbCd == abcd == ab-cd == AB_CD`
  final bool ignoreKeyOtherCases;

  /// Использовать промах включив в поиск ключи
  /// перебором всех возможных форматов.
  ///
  /// `Ab-Cd == a_bcd == abc-d == A_BC_D`
  final bool useKeyExtended;

  /// Отключить промах по ключам
  /// перебором всех возможных форматов.
  ///
  /// `Ab-Cd == a_bcd == abc-d == A_BC_D`
  final bool ignoreKeyExtended;
}
