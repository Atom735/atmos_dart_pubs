import 'dart:async';
import 'dart:typed_data';

import 'package:atmos_filesystem/atmos_filesystem.dart';
import 'package:atmos_web_files_system_access_api/atmos_web_files_system_access_api.dart'
    as fsa;
import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// [FileSystemProvider] backed by a File System Access directory handle.
///
/// URIs use scheme [scheme] (default `fsa`) and a POSIX path relative to
/// [root], e.g. `fsa:///src/main.dart`.
class FsaFileSystemProvider extends FileSystemProvider {
  /// Creates a provider rooted at [root].
  FsaFileSystemProvider(
    this.root, {
    this.scheme = 'fsa',
  });

  /// Directory handle chosen by the user (or obtained otherwise).
  final fsa.FileSystemDirectoryHandle root;

  @override
  final String scheme;

  // ignore: close_sinks
  final _controller = StreamController<List<FileChangeEvent>>.broadcast();

  @override
  int get capabilities =>
      FileSystemProviderCapabilities.fileReadWrite |
      FileSystemProviderCapabilities.pathCaseSensitive;

  @override
  Stream<List<FileChangeEvent>> get onDidChangeFile => _controller.stream;

  List<String> _parts(Uri uri) {
    if (uri.scheme != scheme) {
      throw FileSystemException('Expected scheme "$scheme"', uri: uri);
    }
    return uri.pathSegments.where((s) => s.isNotEmpty).toList();
  }

  Future<fsa.FileSystemDirectoryHandle> _dir(
    List<String> parts, {
    bool create = false,
  }) async {
    var dir = root;
    for (final part in parts) {
      dir = await dir.getDirectoryHandle(
        part,
        options: fsa.GetHandleOptions(create: create),
      );
    }
    return dir;
  }

  Future<(fsa.FileSystemDirectoryHandle parent, String name)> _parent(
    List<String> parts, {
    bool create = false,
  }) async {
    if (parts.isEmpty) {
      throw FileSystemException('Path required');
    }
    final parent =
        await _dir(parts.sublist(0, parts.length - 1), create: create);
    return (parent, parts.last);
  }

  @override
  Future<FileStat> stat(Uri resource) async {
    final parts = _parts(resource);
    if (parts.isEmpty) {
      return const FileStat(
        type: FileType.directory,
        ctime: 0,
        mtime: 0,
        size: 0,
      );
    }
    try {
      final (parent, name) = await _parent(parts);
      try {
        final file = await parent.getFileHandle(name);
        final blob = await file.getFile();
        final size = _jsInt(blob, 'size');
        final mtime = _jsInt(blob, 'lastModified');
        return FileStat(
          type: FileType.file,
          ctime: mtime,
          mtime: mtime,
          size: size,
        );
      } on Object {
        await parent.getDirectoryHandle(name);
        return const FileStat(
          type: FileType.directory,
          ctime: 0,
          mtime: 0,
          size: 0,
        );
      }
    } on Object catch (e) {
      throw FileNotFoundException(resource, cause: e);
    }
  }

  @override
  Future<void> createDirectory(Uri resource) async {
    final parts = _parts(resource);
    if (parts.isEmpty) return;
    await _dir(parts, create: true);
  }

  @override
  Future<List<(String name, int type)>> readDirectory(Uri resource) async {
    final parts = _parts(resource);
    try {
      final dir = await _dir(parts);
      final entries = await dir.entries();
      return [
        for (final (name, handle) in entries)
          (
            name,
            handle.kind == fsa.FileSystemHandleKind.directory
                ? FileType.directory
                : FileType.file,
          ),
      ];
    } on Object catch (e) {
      throw FileNotFoundException(resource, cause: e);
    }
  }

  @override
  Future<void> delete(Uri resource, FileDeleteOptions options) async {
    final parts = _parts(resource);
    if (parts.isEmpty) {
      throw FileSystemException('Cannot delete root', uri: resource);
    }
    final (parent, name) = await _parent(parts);
    try {
      await parent.removeEntry(
        name,
        options: fsa.RemoveEntryOptions(recursive: options.recursive),
      );
    } on Object catch (e) {
      throw FileSystemException('delete failed', uri: resource, cause: e);
    }
  }

  @override
  Future<void> rename(
    Uri from,
    Uri to,
    FileOverwriteOptions options,
  ) async {
    final bytes = await readFile(from);
    await writeFile(
      to,
      bytes,
      FileWriteOptions(create: true, overwrite: options.overwrite),
    );
    await delete(from, const FileDeleteOptions());
  }

  @override
  Future<Uint8List> readFile(Uri resource) async {
    final parts = _parts(resource);
    if (parts.isEmpty) {
      throw FileSystemException('Not a file', uri: resource);
    }
    try {
      final (parent, name) = await _parent(parts);
      final file = await parent.getFileHandle(name);
      return file.readAsBytes();
    } on Object catch (e) {
      throw FileNotFoundException(resource, cause: e);
    }
  }

  @override
  Future<void> writeFile(
    Uri resource,
    Uint8List content,
    FileWriteOptions options,
  ) async {
    final parts = _parts(resource);
    if (parts.isEmpty) {
      throw FileSystemException('Cannot write root', uri: resource);
    }
    try {
      final (parent, name) = await _parent(parts, create: options.create);
      if (!options.overwrite) {
        try {
          await parent.getFileHandle(name);
          throw FileExistsException(resource);
        } on FileExistsException {
          rethrow;
        } on Object {
          if (!options.create) throw FileNotFoundException(resource);
        }
      }
      final file = await parent.getFileHandle(
        name,
        options: const fsa.GetHandleOptions(create: true),
      );
      final writable = await file.createWritable();
      await writable.writeBytes(content);
      await writable.close();
    } on FileSystemException {
      rethrow;
    } on Object catch (e) {
      throw FileSystemException('writeFile failed', uri: resource, cause: e);
    }
  }

  int _jsInt(Object js, String name) {
    if (!jsInteropSupported) return 0;
    final value = jsGetProperty<Object?>(js, name);
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return 0;
  }

  /// Closes the change-event stream.
  Future<void> dispose() => _controller.close();
}
