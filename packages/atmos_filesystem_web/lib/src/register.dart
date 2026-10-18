import 'package:atmos_filesystem/atmos_filesystem.dart';
import 'package:atmos_web_files_system_access_api/atmos_web_files_system_access_api.dart';

import 'fsa_provider.dart';

/// Shows a directory picker and registers an [FsaFileSystemProvider] on [fs].
///
/// Returns the created provider.
Future<FsaFileSystemProvider> registerPickedDirectory(
  AtmosFileSystem fs, {
  DirectoryPickerOptions? options,
  String scheme = 'fsa',
}) async {
  final dir = await showDirectoryPicker(options);
  final provider = FsaFileSystemProvider(dir, scheme: scheme);
  fs.register(provider);
  return provider;
}

/// Registers [root] as an [FsaFileSystemProvider] on [fs].
FsaFileSystemProvider registerDirectoryHandle(
  AtmosFileSystem fs,
  FileSystemDirectoryHandle root, {
  String scheme = 'fsa',
}) {
  final provider = FsaFileSystemProvider(root, scheme: scheme);
  fs.register(provider);
  return provider;
}
