/// Wire format for request/response between host and workers.
abstract final class ParallelMessage {
  /// Request field: job name.
  static const String job = 'job';

  /// Request/response correlation id.
  static const String id = 'id';

  /// Request payload.
  static const String input = 'input';

  /// Response payload.
  static const String result = 'result';

  /// Response error string (if failed).
  static const String error = 'error';

  /// Envelope type: `'request'` / `'response'`.
  static const String type = 'type';

  /// Type value for requests.
  static const String typeRequest = 'request';

  /// Type value for responses.
  static const String typeResponse = 'response';

  /// Builds a request map.
  static Map<String, Object?> request({
    required String id,
    required String job,
    Object? input,
  }) =>
      {
        type: typeRequest,
        ParallelMessage.id: id,
        ParallelMessage.job: job,
        ParallelMessage.input: input,
      };

  /// Builds a success response map.
  static Map<String, Object?> responseOk({
    required String id,
    Object? result,
  }) =>
      {
        type: typeResponse,
        ParallelMessage.id: id,
        ParallelMessage.result: result,
      };

  /// Builds an error response map.
  static Map<String, Object?> responseError({
    required String id,
    required String error,
  }) =>
      {
        type: typeResponse,
        ParallelMessage.id: id,
        ParallelMessage.error: error,
      };
}
