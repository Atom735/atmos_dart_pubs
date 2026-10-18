/// Time unit for epoch-based [DateTime] / [Duration] codecs.
///
/// Единица времени для кодеков [DateTime] / [Duration] на основе epoch.
enum EpochUnit {
  /// Whole seconds.
  ///
  /// Целые секунды.
  seconds,

  /// Milliseconds (default for [DateTime] helpers).
  ///
  /// Миллисекунды (по умолчанию для хелперов [DateTime]).
  milliseconds,

  /// Microseconds (native [Duration] resolution).
  ///
  /// Микросекунды (родное разрешение [Duration]).
  microseconds,
}
