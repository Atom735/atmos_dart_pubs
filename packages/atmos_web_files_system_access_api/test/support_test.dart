import 'package:atmos_web_files_system_access_api/atmos_web_files_system_access_api.dart';
import 'package:test/test.dart';

void main() {
  test('FSA is unsupported on VM', () {
    expect(isFileSystemAccessApiSupported, isFalse);
  });

  test('pickers throw when unsupported', () async {
    expect(showDirectoryPicker(), throwsA(isA<FileSystemAccessException>()));
  });
}
