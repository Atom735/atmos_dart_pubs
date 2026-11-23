part of 'atmos_http_request.dart';

/// Multipart form request (fields + optional file parts as bytes).
///
/// Multipart form-запрос (поля + опциональные файловые части как байты).
@immutable
final class AtmosHttpRequestMultipart extends AtmosHttpRequestBase {
  /// Creates a multipart request.
  ///
  /// Создаёт multipart-запрос.
  const AtmosHttpRequestMultipart(
    super.method,
    super.uri, {
    this.fields = const {},
    this.files = const {},
    this.fileNames = const {},
    this.headers = const {},
  }) : super(isStreamedRequest: true, isStreamedResponse: false);

  /// Text form fields.
  final Map<String, String> fields;

  /// File parts: field name → bytes.
  final Map<String, List<int>> files;

  /// Optional file names keyed like [files].
  final Map<String, String> fileNames;

  /// Extra headers (multipart boundary is set by the client).
  final Map<String, String> headers;
}
