import 'dart:convert';

import 'package:http/http.dart' as http;

import '../request/atmos_http_request.dart';

/// Thin typed wrapper over [`package:http`](https://pub.dev/packages/http).
///
/// Тонкая типизированная обёртка над `package:http`.
// ignore: one_member_abstracts
abstract class AtmosHttpClient {
  /// Sends [request] and returns the raw [http.Response].
  Future<http.Response> send(AtmosHttpRequestBase request);
}

/// Default [AtmosHttpClient] using [http.Client].
class AtmosHttpClientHttp implements AtmosHttpClient {
  /// Creates a client. Owns [inner] unless [closeInner] is false.
  AtmosHttpClientHttp({http.Client? inner, bool closeInner = true})
      : _inner = inner ?? http.Client(),
        _closeInner = closeInner && inner == null;

  final http.Client _inner;
  final bool _closeInner;

  /// Closes the underlying client when owned.
  void close() {
    if (_closeInner) _inner.close();
  }

  @override
  Future<http.Response> send(AtmosHttpRequestBase request) async {
    switch (request) {
      case AtmosHttpRequestJson():
        final headers = <String, String>{
          'content-type': 'application/json; charset=utf-8',
          ...request.headers,
        };
        final raw = request.body;
        final String? body;
        if (raw == null) {
          body = null;
        } else if (raw is String) {
          body = raw;
        } else {
          body = jsonEncode(raw);
        }
        return _dispatch(
          request.method,
          request.uri,
          headers: headers,
          body: body,
        );
      case AtmosHttpRequestMultipart():
        final multipart = http.MultipartRequest(request.method, request.uri)
          ..headers.addAll(request.headers)
          ..fields.addAll(request.fields);
        for (final e in request.files.entries) {
          multipart.files.add(
            http.MultipartFile.fromBytes(
              e.key,
              e.value,
              filename: request.fileNames[e.key],
            ),
          );
        }
        final streamed = await _inner.send(multipart);
        return http.Response.fromStream(streamed);
    }
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) {
    final m = method.toUpperCase();
    switch (m) {
      case 'GET':
        return _inner.get(uri, headers: headers);
      case 'POST':
        return _inner.post(uri, headers: headers, body: body);
      case 'PUT':
        return _inner.put(uri, headers: headers, body: body);
      case 'PATCH':
        return _inner.patch(uri, headers: headers, body: body);
      case 'DELETE':
        return _inner.delete(uri, headers: headers, body: body);
      default:
        final req = http.Request(m, uri);
        if (headers != null) req.headers.addAll(headers);
        if (body != null) req.body = body;
        return _inner.send(req).then(http.Response.fromStream);
    }
  }
}
