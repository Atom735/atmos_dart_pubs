/// Capability flags advertised by a `FileSystemProvider`.
abstract final class FileSystemProviderCapabilities {
  /// No capabilities.
  static const int none = 0;

  /// Supports unbuffered `readFile` / `writeFile`.
  static const int fileReadWrite = 1 << 1;

  /// Supports low-level open / read / write / close.
  static const int fileOpenReadWriteClose = 1 << 2;

  /// Supports `copy`.
  static const int fileFolderCopy = 1 << 3;

  /// Supports streaming reads (reserved for future adapters).
  static const int fileReadStream = 1 << 4;

  /// Paths are case-sensitive.
  static const int pathCaseSensitive = 1 << 10;

  /// Provider is entirely readonly.
  static const int readonly = 1 << 11;

  /// Delete may move to trash when requested.
  static const int trash = 1 << 12;

  /// Atomic read support.
  static const int fileAtomicRead = 1 << 14;

  /// Atomic write support.
  static const int fileAtomicWrite = 1 << 15;

  /// Atomic delete support.
  static const int fileAtomicDelete = 1 << 16;

  /// Atomic clone/copy-file support.
  static const int fileClone = 1 << 17;

  /// Realpath resolution support.
  static const int fileRealpath = 1 << 18;

  /// Append writes support.
  static const int fileAppend = 1 << 19;
}
