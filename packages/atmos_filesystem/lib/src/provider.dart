import 'dart:typed_data';

import 'capabilities.dart';
import 'errors.dart';
import 'file_stat.dart';
import 'watch.dart';

/// Options for [FileSystemProvider.writeFile].
class FileWriteOptions {
  /// Creates write options.
  const FileWriteOptions({
    this.create = true,
    this.overwrite = true,
    this.unlock = false,
    this.atomic = false,
  });

  /// Create the file if missing.
  final bool create;

  /// Overwrite an existing file.
  final bool overwrite;

  /// Attempt to unlock a locked file before writing.
  final bool unlock;

  /// Prefer an atomic write when supported.
  final bool atomic;
}

/// Options for [FileSystemProvider.delete].
class FileDeleteOptions {
  /// Creates delete options.
  const FileDeleteOptions({
    this.recursive = false,
    this.useTrash = false,
    this.atomic = false,
  });

  /// Delete directories recursively.
  final bool recursive;

  /// Prefer trash when the provider supports it.
  final bool useTrash;

  /// Prefer atomic delete when supported.
  final bool atomic;
}

/// Options for rename / copy overwrite behaviour.
class FileOverwriteOptions {
  /// Creates overwrite options.
  const FileOverwriteOptions({this.overwrite = false});

  /// Replace the destination if it exists.
  final bool overwrite;
}

/// Options for low-level [FileSystemProvider.open].
class FileOpenOptions {
  /// Creates open options.
  const FileOpenOptions({this.create = false});

  /// Create the file when opening for write.
  final bool create;
}

/// A disposable watch subscription.
// ignore: one_member_abstracts
abstract class FileSystemWatchSubscription {
  /// Cancels the watch.
  void dispose();
}

/// Provider interface inspired by VS Code’s `FileSystemProvider`.
///
/// Implement the members your backend supports and advertise them via
/// [capabilities]. Optional methods throw [FileSystemUnavailableException]
/// by default.
abstract class FileSystemProvider {
  /// Capability bitmask ([FileSystemProviderCapabilities]).
  int get capabilities;

  /// URI scheme this provider owns (e.g. `file`, `mem`, `fsa`).
  String get scheme;

  /// Fired when watched files change (may be a broadcast never used).
  Stream<List<FileChangeEvent>> get onDidChangeFile;

  /// Returns metadata for [resource].
  Future<FileStat> stat(Uri resource);

  /// Creates a directory at [resource].
  Future<void> createDirectory(Uri resource);

  /// Lists directory children as `(name, FileType flags)`.
  Future<List<(String name, int type)>> readDirectory(Uri resource);

  /// Deletes [resource].
  Future<void> delete(Uri resource, FileDeleteOptions options);

  /// Renames / moves [from] to [to].
  Future<void> rename(Uri from, Uri to, FileOverwriteOptions options);

  /// Copies [from] to [to] when [FileSystemProviderCapabilities.fileFolderCopy]
  /// is set.
  Future<void> copy(Uri from, Uri to, FileOverwriteOptions options) {
    throw FileSystemUnavailableException('copy is not supported', uri: from);
  }

  /// Reads the entire file.
  Future<Uint8List> readFile(Uri resource) {
    throw FileSystemUnavailableException(
      'readFile is not supported',
      uri: resource,
    );
  }

  /// Writes the entire file.
  Future<void> writeFile(
    Uri resource,
    Uint8List content,
    FileWriteOptions options,
  ) {
    throw FileSystemUnavailableException(
      'writeFile is not supported',
      uri: resource,
    );
  }

  /// Opens a low-level file descriptor when
  /// [FileSystemProviderCapabilities.fileOpenReadWriteClose] is set.
  Future<int> open(Uri resource, FileOpenOptions options) {
    throw FileSystemUnavailableException(
      'open is not supported',
      uri: resource,
    );
  }

  /// Closes a descriptor from [open].
  Future<void> close(int fd) {
    throw FileSystemUnavailableException('close is not supported');
  }

  /// Reads into [data] at Dart [offset] for [length] bytes from file [pos].
  Future<int> read(
    int fd,
    int pos,
    Uint8List data,
    int offset,
    int length,
  ) {
    throw FileSystemUnavailableException('read is not supported');
  }

  /// Writes from [data] at Dart [offset] for [length] bytes to file [pos].
  Future<int> write(
    int fd,
    int pos,
    Uint8List data,
    int offset,
    int length,
  ) {
    throw FileSystemUnavailableException('write is not supported');
  }

  /// Watches [resource]; default is a no-op subscription.
  FileSystemWatchSubscription watch(Uri resource, WatchOptions options) {
    return const _NoopWatchSubscription();
  }
}

class _NoopWatchSubscription implements FileSystemWatchSubscription {
  const _NoopWatchSubscription();

  @override
  void dispose() {}
}

/// Returns whether [capabilities] include [flag].
bool hasCapability(int capabilities, int flag) =>
    (capabilities & flag) == flag;
