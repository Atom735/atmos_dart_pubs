import 'package:atmos_filesystem_web/atmos_filesystem_web.dart';
import 'package:test/test.dart';

void main() {
  test('library exports FsaFileSystemProvider', () {
    expect(FsaFileSystemProvider, isNotNull);
  });
}
