import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_filesystem/atmos_filesystem.dart';
import 'package:test/test.dart';

void main() {
  late AtmosFileSystem fs;

  setUp(() {
    fs = AtmosFileSystem()..register(MemoryFileSystemProvider());
  });

  test('write / read / list', () async {
    final dir = Uri.parse('mem:///docs');
    final file = Uri.parse('mem:///docs/hi.txt');

    await fs.createDirectory(dir);
    await fs.writeFile(file, Uint8List.fromList(utf8.encode('hello')));

    expect(utf8.decode(await fs.readFile(file)), 'hello');
    expect(await fs.readDirectory(dir), [
      ('hi.txt', FileType.file),
    ]);
    final st = await fs.stat(file);
    expect(st.isFile, isTrue);
    expect(st.size, 5);
  });

  test('open / read / write / close', () async {
    final file = Uri.parse('mem:///bin.dat');
    final provider = fs.providerFor(file) as MemoryFileSystemProvider;
    await fs.writeFile(file, Uint8List.fromList([1, 2, 3]));

    final fd = await provider.open(file, const FileOpenOptions());
    final buf = Uint8List(2);
    expect(await provider.read(fd, 1, buf, 0, 2), 2);
    expect(buf, [2, 3]);
    await provider.write(fd, 0, Uint8List.fromList([9]), 0, 1);
    await provider.close(fd);
    expect(await fs.readFile(file), [9, 2, 3]);
  });

  test('missing scheme throws', () {
    expect(
      () => fs.stat(Uri.parse('other:///x')),
      throwsA(isA<FileSystemUnavailableException>()),
    );
  });
}
