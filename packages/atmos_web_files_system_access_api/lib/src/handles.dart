import 'dart:typed_data';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';
import 'options.dart';

/// Kind of a [FileSystemHandle].
enum FileSystemHandleKind {
  /// A file handle.
  file,

  /// A directory handle.
  directory,
}

FileSystemHandleKind _parseKind(String kind) {
  switch (kind) {
    case 'file':
      return FileSystemHandleKind.file;
    case 'directory':
      return FileSystemHandleKind.directory;
    default:
      throw FileSystemAccessException('Unknown handle kind: $kind');
  }
}

/// Base handle wrapping a JS `FileSystemHandle`.
class FileSystemHandle {
  /// Wraps a raw JS handle object.
  FileSystemHandle(this.jsObject)
      : name = jsGetProperty<String>(jsObject, 'name'),
        kind = _parseKind(jsGetProperty<String>(jsObject, 'kind'));

  /// Underlying JS handle.
  final Object jsObject;

  /// Entry name.
  final String name;

  /// File or directory.
  final FileSystemHandleKind kind;

  /// Queries permission state (`granted` / `denied` / `prompt`).
  Future<String> queryPermission([
    FileSystemHandlePermissionDescriptor descriptor =
        const FileSystemHandlePermissionDescriptor(),
  ]) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'queryPermission',
      [descriptor.toJs()],
    );
    return jsMaybePromiseToFuture<String>(result);
  }

  /// Requests permission; returns state string.
  Future<String> requestPermission([
    FileSystemHandlePermissionDescriptor descriptor =
        const FileSystemHandlePermissionDescriptor(),
  ]) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'requestPermission',
      [descriptor.toJs()],
    );
    return jsMaybePromiseToFuture<String>(result);
  }

  /// Whether [other] refers to the same entry.
  Future<bool> isSameEntry(FileSystemHandle other) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'isSameEntry',
      [other.jsObject],
    );
    return jsMaybePromiseToFuture<bool>(result);
  }

  /// Casts to a typed handle based on [kind].
  FileSystemHandle asTyped() {
    switch (kind) {
      case FileSystemHandleKind.file:
        return FileSystemFileHandle(jsObject);
      case FileSystemHandleKind.directory:
        return FileSystemDirectoryHandle(jsObject);
    }
  }
}

/// File handle (`FileSystemFileHandle`).
class FileSystemFileHandle extends FileSystemHandle {
  /// Wraps a JS file handle.
  FileSystemFileHandle(super.jsObject);

  /// Returns a JS `File` blob object.
  Future<Object> getFile() async {
    final result = jsCallMethod<Object>(jsObject, 'getFile');
    return jsMaybePromiseToFuture<Object>(result);
  }

  /// Reads the whole file as bytes.
  Future<Uint8List> readAsBytes() async {
    final file = await getFile();
    final buffer = await jsMaybePromiseToFuture<Object>(
      jsCallMethod<Object>(file, 'arrayBuffer'),
    );
    final ctor = jsGlobal('Uint8Array');
    if (ctor == null) {
      throw FileSystemAccessException('Uint8Array is not available');
    }
    final view = jsConstruct(ctor, [buffer]);
    return jsBytesFromUint8Array(view);
  }

  /// Opens a writable stream (optionally keep existing data).
  Future<FileSystemWritableFileStream> createWritable({
    bool keepExistingData = false,
  }) async {
    final opts = jsNewObject();
    jsSetProperty(opts, 'keepExistingData', keepExistingData);
    final result = jsCallMethod<Object>(jsObject, 'createWritable', [opts]);
    final stream = await jsMaybePromiseToFuture<Object>(result);
    return FileSystemWritableFileStream(stream);
  }
}

/// Directory handle (`FileSystemDirectoryHandle`).
class FileSystemDirectoryHandle extends FileSystemHandle {
  /// Wraps a JS directory handle.
  FileSystemDirectoryHandle(super.jsObject);

  /// Resolves a file child by [name].
  Future<FileSystemFileHandle> getFileHandle(
    String name, {
    GetHandleOptions options = const GetHandleOptions(),
  }) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'getFileHandle',
      [name, options.toJs()],
    );
    final handle = await jsMaybePromiseToFuture<Object>(result);
    return FileSystemFileHandle(handle);
  }

  /// Resolves a directory child by [name].
  Future<FileSystemDirectoryHandle> getDirectoryHandle(
    String name, {
    GetHandleOptions options = const GetHandleOptions(),
  }) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'getDirectoryHandle',
      [name, options.toJs()],
    );
    final handle = await jsMaybePromiseToFuture<Object>(result);
    return FileSystemDirectoryHandle(handle);
  }

  /// Removes a child entry.
  Future<void> removeEntry(
    String name, {
    RemoveEntryOptions options = const RemoveEntryOptions(),
  }) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'removeEntry',
      [name, options.toJs()],
    );
    await jsMaybePromiseToFuture<void>(result);
  }

  /// Relative path from this directory to [possibleDescendant], or `null`.
  Future<List<String>?> resolve(FileSystemHandle possibleDescendant) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'resolve',
      [possibleDescendant.jsObject],
    );
    final path = await jsMaybePromiseToFuture<Object?>(result);
    if (path == null) return null;
    final lengthRaw = jsGetProperty<Object?>(path, 'length');
    if (lengthRaw is! num) return null;
    final length = lengthRaw.toInt();
    return [
      for (var i = 0; i < length; i++) jsGetProperty<String>(path, i),
    ];
  }

  /// Lists child names (via async iterator `keys()`).
  Future<List<String>> keys() async {
    final items = await _collectJsIterator('keys');
    return items.cast<String>();
  }

  /// Lists child handles (via async iterator `values()`).
  Future<List<FileSystemHandle>> values() async {
    final items = await _collectJsIterator('values');
    return [
      for (final item in items) FileSystemHandle(item).asTyped(),
    ];
  }

  /// Lists `(name, handle)` entries.
  Future<List<(String, FileSystemHandle)>> entries() async {
    final items = await _collectJsIterator('entries');
    return [
      for (final item in items)
        (
          jsGetProperty<String>(item, 0),
          FileSystemHandle(jsGetProperty<Object>(item, 1)).asTyped(),
        ),
    ];
  }

  /// Chromium returns an async iterator with `next()` from keys/values/entries.
  Future<List<Object>> _collectJsIterator(String method) async {
    final iterator = jsCallMethod<Object>(jsObject, method);
    return jsCollectAsyncIterator(iterator);
  }
}

/// Writable stream returned by [FileSystemFileHandle.createWritable].
class FileSystemWritableFileStream {
  /// Wraps a JS writable stream.
  FileSystemWritableFileStream(this.jsObject);

  /// Underlying JS stream.
  final Object jsObject;

  /// Writes [bytes] as a JS `Uint8Array`.
  Future<void> writeBytes(Uint8List bytes) async {
    final result = jsCallMethod<Object>(
      jsObject,
      'write',
      [jsUint8ArrayFromBytes(bytes)],
    );
    await jsMaybePromiseToFuture<void>(result);
  }

  /// Writes a JS-compatible [data] payload (string, Blob, BufferSource, …).
  Future<void> write(Object data) async {
    final result = jsCallMethod<Object>(jsObject, 'write', [data]);
    await jsMaybePromiseToFuture<void>(result);
  }

  /// Seeks to [position].
  Future<void> seek(int position) async {
    final result = jsCallMethod<Object>(jsObject, 'seek', [position]);
    await jsMaybePromiseToFuture<void>(result);
  }

  /// Truncates to [size].
  Future<void> truncate(int size) async {
    final result = jsCallMethod<Object>(jsObject, 'truncate', [size]);
    await jsMaybePromiseToFuture<void>(result);
  }

  /// Closes the stream.
  Future<void> close() async {
    final result = jsCallMethod<Object>(jsObject, 'close');
    await jsMaybePromiseToFuture<void>(result);
  }
}
