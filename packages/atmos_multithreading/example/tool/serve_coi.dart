// ignore_for_file: avoid_print

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

/// Serves `build/web` with COOP/COEP so SharedArrayBuffer works.
///
/// ```bash
/// flutter build web
/// dart run tool/serve_coi.dart
/// # open http://localhost:8080
/// ```
Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.parse(args.first) : 8080;
  final root = Directory('build/web');
  if (!root.existsSync()) {
    stderr.writeln('Missing build/web — run `flutter build web` first.');
    exitCode = 1;
    return;
  }

  final staticHandler = createStaticHandler(
    root.path,
    defaultDocument: 'index.html',
  );

  final handler = Pipeline().addMiddleware((inner) {
    return (request) async {
      final response = await inner(request);
      return response.change(
        headers: const {
          'Cross-Origin-Opener-Policy': 'same-origin',
          'Cross-Origin-Embedder-Policy': 'require-corp',
        },
      );
    };
  }).addHandler(staticHandler);

  final server =
      await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
  print(
    'Serving ${root.path} on http://${server.address.host}:${server.port}\n'
    'COOP/COEP enabled — SharedArrayBuffer should work '
    '(check window.crossOriginIsolated).',
  );
}
