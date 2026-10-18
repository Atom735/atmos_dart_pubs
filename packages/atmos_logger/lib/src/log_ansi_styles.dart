import 'package:io/ansi.dart';

import 'log_data.dart';
import 'log_level.dart';

abstract class LogAnsiStyles {
  static const title = <List<AnsiCode>>[
    [styleBold],
    [styleBold, lightGray],
    [styleBold, lightBlue],
    [styleBold, lightGreen],
    [styleBold, lightYellow],
    [styleBold, lightRed],
    [styleBold, backgroundLightRed, black],
    [styleBold, lightMagenta],
  ];
  static String wrapLevel(LogData data) =>
      wrapWith(LogLevel.names[data.level], title[data.level])!;
  static String wrapTitle(LogData data) =>
      wrapWith(data.title, title[data.level])!;
  static const body = <List<AnsiCode>>[
    [],
    [lightGray],
    [lightBlue],
    [lightGreen],
    [lightYellow],
    [lightRed],
    [backgroundLightRed, black],
    [lightMagenta],
  ];
  static String wrapBody(LogData data) =>
      data.body.isNotEmpty ? '${wrapWith(data.body, body[data.level])!}\n' : '';
}
