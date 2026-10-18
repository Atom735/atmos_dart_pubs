/// File type flags (compatible with VS Code `FileType` bit layout).
abstract final class FileType {
  /// Unknown / absent.
  static const int unknown = 0;

  /// Regular file.
  static const int file = 1;

  /// Directory.
  static const int directory = 2;

  /// Symbolic link (may be OR-ed with [file] or [directory]).
  static const int symbolicLink = 64;
}

/// Optional permission bits on `FileStat` (VS Code–style, not full Unix mode).
abstract final class FilePermission {
  /// Resource is readonly for the consumer.
  static const int readonly = 1;
}
