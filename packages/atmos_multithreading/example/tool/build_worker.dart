// ignore_for_file: avoid_print

import 'dart:io';

/// Compiles [worker/main.dart] → [web/counter_worker.js].
///
/// Run from `example/`:
/// ```bash
/// dart run tool/build_worker.dart
/// ```
Future<void> main(List<String> args) async {
  final exampleRoot = Directory.current;
  final worker = File.fromUri(exampleRoot.uri.resolve('worker/main.dart'));
  final out = File.fromUri(exampleRoot.uri.resolve('web/counter_worker.js'));

  if (!worker.existsSync()) {
    stderr.writeln('Missing ${worker.path}');
    exitCode = 1;
    return;
  }

  out.parent.createSync(recursive: true);

  print('Compiling Dart worker → ${out.path}');
  final result = await Process.run(
    Platform.resolvedExecutable,
    [
      'compile',
      'js',
      '-O1',
      '--no-source-maps',
      '-o',
      out.path,
      worker.path,
    ],
    workingDirectory: exampleRoot.path,
    runInShell: true,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    exitCode = result.exitCode;
    return;
  }

  final sizeKb = (out.lengthSync() / 1024).toStringAsFixed(1);
  print('OK ($sizeKb KiB)');
}
