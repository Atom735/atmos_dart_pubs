import 'file_type.dart';

/// Metadata for a filesystem resource (VS Code `FileStat`-like).
class FileStat {
  /// Creates a stat snapshot.
  const FileStat({
    required this.type,
    required this.ctime,
    required this.mtime,
    required this.size,
    this.permissions,
  });

  /// [FileType] flags.
  final int type;

  /// Creation time in milliseconds since epoch.
  final int ctime;

  /// Modification time in milliseconds since epoch.
  final int mtime;

  /// Size in bytes (0 for directories).
  final int size;

  /// Optional [FilePermission] bitmask.
  final int? permissions;

  /// Whether this entry is a file (ignoring symlink bit).
  bool get isFile => (type & FileType.file) != 0;

  /// Whether this entry is a directory (ignoring symlink bit).
  bool get isDirectory => (type & FileType.directory) != 0;

  /// Whether the symlink bit is set.
  bool get isSymbolicLink => (type & FileType.symbolicLink) != 0;
}
