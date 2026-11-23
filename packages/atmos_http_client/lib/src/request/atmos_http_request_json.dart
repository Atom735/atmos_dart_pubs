part of 'atmos_http_request.dart';

/// JSON body request (`Content-Type: application/json`).
///
/// Запрос с JSON-телом (`Content-Type: application/json`).
@immutable
final class AtmosHttpRequestJson extends AtmosHttpRequestBase {
  /// Creates a JSON request.
  ///
  /// Создаёт JSON-запрос.
  const AtmosHttpRequestJson(
    super.method,
    super.uri, {
    this.body,
    this.headers = const {},
  }) : super(isStreamedRequest: false, isStreamedResponse: false);

  /// JSON-encodable body (map / list / primitives), or raw string.
  ///
  /// JSON-совместимое тело (map / list / примитивы) или готовая строка.
  final Object? body;

  /// Extra request headers.
  ///
  /// Дополнительные заголовки.
  final Map<String, String> headers;
}
