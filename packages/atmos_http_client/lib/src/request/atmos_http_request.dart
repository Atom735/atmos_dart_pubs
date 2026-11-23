library atmos_http_request;

import 'package:meta/meta.dart';

part 'atmos_http_request_json.dart';
part 'atmos_http_request_multipart.dart';

/// Базовый класс данных запроса.
@immutable
sealed class AtmosHttpRequestBase {
  /// Метод запроса.
  final String method;

  /// Является ли запрос потоковым.
  final bool isStreamedRequest;

  /// Является ли ответ потоковым.
  final bool isStreamedResponse;

  /// Ссылка запроса.
  final Uri uri;

  const AtmosHttpRequestBase(
    this.method,
    this.uri, {
    this.isStreamedRequest = false,
    this.isStreamedResponse = false,
  });
}
