import 'dart:async';
import 'dart:typed_data';

import 'capabilities.dart';
import 'errors.dart';
import 'file_stat.dart';
import 'file_type.dart';
import 'provider.dart';
import 'watch.dart';

class _MemNode {
  _MemNode.dir()
      : type = FileType.directory,
        children = {},
        data = null,
        ctime = _now(),
        mtime = _now();

  _MemNode.file([Uint8List? bytes])
      : type = FileType.file,
        children = null,
        data = bytes ?? Uint8List(0),
        ctime = _now(),
        mtime = _now();

  final int type;
  final Map<String, _MemNode>? children;
  Uint8List? data;
  final int ctime;
  int mtime;

  int get size => data?.length ?? 0;

  static int _now() => DateTime.now().millisecondsSinceEpoch;
}

/// In-memory [FileSystemProvider] with scheme `mem`.
///
/// URIs look like `mem:///path/to/file`. The authority is ignored; path is
/// POSIX-style (`/` separated). Root is `mem:///` or `mem:///`.
class MemoryFileSystemProvider extends FileSystemProvider {
  /// Creates a provider with an empty root directory.
  MemoryFileSystemProvider();

  final _MemNode _root = _MemNode.dir();
  final _controller = StreamController<List<FileChangeEvent>>.broadcast();
  final Map<int, _OpenFile> _fds = {};
  var _nextFd = 1;

  @override
  String get scheme => 'mem';

  @override
  int get capabilities =>
      FileSystemProviderCapabilities.fileReadWrite |
      FileSystemProviderCapabilities.fileOpenReadWriteClose |
      FileSystemProviderCapabilities.fileFolderCopy |
      FileSystemProviderCapabilities.pathCaseSensitive;

  @override
  Stream<List<FileChangeEvent>> get onDidChangeFile => _controller.stream;

  List<String> _parts(Uri uri) {
    _ensureScheme(uri);
    return uri.pathSegments.where((s) => s.isNotEmpty).toList();
  }

  void _ensureScheme(Uri uri) {
    if (uri.scheme != scheme) {
      throw FileSystemException(
        'Expected scheme "$scheme"',
        uri: uri,
      );
    }
  }

  (_MemNode parent, String name)? _parentOf(List<String> parts) {
    if (parts.isEmpty) return null;
    var node = _root;
    for (var i = 0; i < parts.length - 1; i++) {
      final next = node.children?[parts[i]];
      if (next == null || next.children == null) return null;
      node = next;
    }
    return (node, parts.last);
  }

  _MemNode? _lookup(List<String> parts) {
    if (parts.isEmpty) return _root;
    var node = _root;
    for (final part in parts) {
      final next = node.children?[part];
      if (next == null) return null;
      node = next;
    }
    return node;
  }

  void _emit(FileChangeType type, Uri uri) {
    if (_controller.hasListener) {
      _controller.add([FileChangeEvent(type, uri)]);
    }
  }

  @override
  Future<FileStat> stat(Uri resource) async {
    final node = _lookup(_parts(resource));
    if (node == null) throw FileNotFoundException(resource);
    return FileStat(
      type: node.type,
      ctime: node.ctime,
      mtime: node.mtime,
      size: node.size,
    );
  }

  @override
  Future<void> createDirectory(Uri resource) async {
    final parts = _parts(resource);
    if (parts.isEmpty) return;
    final parentInfo = _parentOf(parts);
    if (parentInfo == null) {
      // Ensure intermediate directories.
      var node = _root;
      for (final part in parts) {
        final children = node.children;
        if (children == null) {
          throw FileSystemException('Not a directory', uri: resource);
        }
        final existing = children[part];
        if (existing == null) {
          final created = _MemNode.dir();
          children[part] = created;
          node = created;
        } else if (existing.children == null) {
          throw FileExistsException(resource);
        } else {
          node = existing;
        }
      }
      _emit(FileChangeType.created, resource);
      return;
    }
    final (parent, name) = parentInfo;
    final children = parent.children;
    if (children == null) {
      throw FileSystemException('Not a directory', uri: resource);
    }
    if (children.containsKey(name)) {
      throw FileExistsException(resource);
    }
    children[name] = _MemNode.dir();
    parent.mtime = _MemNode._now();
    _emit(FileChangeType.created, resource);
  }

  @override
  Future<List<(String name, int type)>> readDirectory(Uri resource) async {
    final node = _lookup(_parts(resource));
    if (node == null) throw FileNotFoundException(resource);
    final children = node.children;
    if (children == null) {
      throw FileSystemException('Not a directory', uri: resource);
    }
    return [
      for (final e in children.entries) (e.key, e.value.type),
    ];
  }

  @override
  Future<void> delete(Uri resource, FileDeleteOptions options) async {
    final parts = _parts(resource);
    if (parts.isEmpty) {
      throw FileSystemException('Cannot delete root', uri: resource);
    }
    final parentInfo = _parentOf(parts);
    if (parentInfo == null) throw FileNotFoundException(resource);
    final (parent, name) = parentInfo;
    final children = parent.children;
    final target = children?[name];
    if (target == null) throw FileNotFoundException(resource);
    if (target.children != null &&
        target.children!.isNotEmpty &&
        !options.recursive) {
      throw FileSystemException(
        'Directory not empty',
        uri: resource,
      );
    }
    children!.remove(name);
    parent.mtime = _MemNode._now();
    _emit(FileChangeType.deleted, resource);
  }

  @override
  Future<void> rename(
    Uri from,
    Uri to,
    FileOverwriteOptions options,
  ) async {
    final data = await readFile(from);
    final fromStat = await stat(from);
    if (fromStat.isDirectory) {
      throw FileSystemUnavailableException(
        'Directory rename is not implemented in memory provider',
        uri: from,
      );
    }
    await writeFile(
      to,
      data,
      FileWriteOptions(create: true, overwrite: options.overwrite),
    );
    await delete(from, const FileDeleteOptions());
  }

  @override
  Future<void> copy(Uri from, Uri to, FileOverwriteOptions options) async {
    final data = await readFile(from);
    await writeFile(
      to,
      Uint8List.fromList(data),
      FileWriteOptions(create: true, overwrite: options.overwrite),
    );
  }

  @override
  Future<Uint8List> readFile(Uri resource) async {
    final node = _lookup(_parts(resource));
    if (node == null) throw FileNotFoundException(resource);
    if (node.data == null) {
      throw FileSystemException('Not a file', uri: resource);
    }
    return Uint8List.fromList(node.data!);
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

    // Ensure parent directories.
    final parentParts = parts.sublist(0, parts.length - 1);
    if (parentParts.isNotEmpty) {
      final parentUri = resource.replace(pathSegments: parentParts);
      if (_lookup(parentParts) == null) {
        if (!options.create) throw FileNotFoundException(resource);
        await createDirectory(parentUri);
      }
    }

    final parentInfo = _parentOf(parts);
    if (parentInfo == null) throw FileNotFoundException(resource);
    final (parent, name) = parentInfo;
    final children = parent.children!;
    final existing = children[name];
    if (existing == null) {
      if (!options.create) throw FileNotFoundException(resource);
      children[name] = _MemNode.file(Uint8List.fromList(content));
      _emit(FileChangeType.created, resource);
    } else {
      if (existing.children != null) {
        throw FileSystemException('Is a directory', uri: resource);
      }
      if (!options.overwrite) throw FileExistsException(resource);
      existing.data = Uint8List.fromList(content);
      existing.mtime = _MemNode._now();
      _emit(FileChangeType.changed, resource);
    }
    parent.mtime = _MemNode._now();
  }

  @override
  Future<int> open(Uri resource, FileOpenOptions options) async {
    if (options.create) {
      try {
        await stat(resource);
      } on FileNotFoundException {
        await writeFile(
          resource,
          Uint8List(0),
          const FileWriteOptions(create: true, overwrite: true),
        );
      }
    }
    final node = _lookup(_parts(resource));
    if (node == null) throw FileNotFoundException(resource);
    if (node.data == null) {
      throw FileSystemException('Not a file', uri: resource);
    }
    final fd = _nextFd++;
    _fds[fd] = _OpenFile(node);
    return fd;
  }

  @override
  Future<void> close(int fd) async {
    _fds.remove(fd);
  }

  @override
  Future<int> read(
    int fd,
    int pos,
    Uint8List data,
    int offset,
    int length,
  ) async {
    final open = _fds[fd];
    if (open == null) {
      throw FileSystemException('Invalid fd $fd');
    }
    final src = open.node.data!;
    if (pos >= src.length) return 0;
    final toRead = (length < src.length - pos) ? length : src.length - pos;
    data.setRange(offset, offset + toRead, src, pos);
    return toRead;
  }

  @override
  Future<int> write(
    int fd,
    int pos,
    Uint8List data,
    int offset,
    int length,
  ) async {
    final open = _fds[fd];
    if (open == null) {
      throw FileSystemException('Invalid fd $fd');
    }
    final node = open.node;
    final current = node.data ?? Uint8List(0);
    final end = pos + length;
    final next = Uint8List(end > current.length ? end : current.length);
    next.setRange(0, current.length, current);
    next.setRange(pos, pos + length, data, offset);
    node.data = next;
    node.mtime = _MemNode._now();
    return length;
  }

  /// Releases the change stream.
  Future<void> dispose() => _controller.close();
}

class _OpenFile {
  _OpenFile(this.node);
  final _MemNode node;
}
