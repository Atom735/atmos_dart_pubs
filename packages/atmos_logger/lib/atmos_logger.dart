/// Composable logger for Dart and Flutter.
///
/// Компонуемый логгер для Dart и Flutter.
///
/// Import `atmos_logger_io.dart` when you need `LoggerFile`.
library atmos_logger;

export 'src/log_data.dart';
export 'src/log_level.dart';
export 'src/logger.dart';
export 'src/logger_broadcast.dart';
export 'src/logger_buffer.dart';
export 'src/logger_callback.dart';
export 'src/logger_console_stub.dart'
    if (dart.library.io) 'src/logger_console_vm.dart'
    if (dart.library.html) 'src/logger_console_web.dart';
export 'src/logger_filter.dart';
export 'src/logger_named.dart';
export 'src/logger_print.dart';
