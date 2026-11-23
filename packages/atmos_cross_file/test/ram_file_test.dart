import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_cross_file/atmos_cross_file.dart';
import 'package:test/test.dart';

void main() {
  test('AtmosXFileRam readChunk and readAsBytes', () async {
    final bytes = Uint8List.fromList(utf8.encode('hello world'));
    final file = AtmosXFileRam(
      name: 'hello.txt',
      path: 'memory://hello.txt',
      nameExt: 'txt',
      bytes: bytes,
      mimeType: 'text/plain',
    );

    expect(file.size, bytes.length);
    expect(await file.readAsBytes(), bytes);
    expect(await file.readChunk(0, 5), utf8.encode('hello'));
    expect(await file.readAsString(), 'hello world');
  });
}
