/// Kind of change reported by a file watcher.
enum FileChangeType {
  /// Entry changed.
  changed,

  /// Entry created.
  created,

  /// Entry deleted.
  deleted,
}

/// A single change event.
class FileChangeEvent {
  /// Creates a change event.
  const FileChangeEvent(this.type, this.uri);

  /// What happened.
  final FileChangeType type;

  /// Affected resource.
  final Uri uri;
}

/// Options for `FileSystemProvider.watch`.
class WatchOptions {
  /// Creates watch options.
  const WatchOptions({
    this.recursive = false,
    this.excludes = const [],
  });

  /// Watch nested directories.
  final bool recursive;

  /// Glob-like excludes (provider-defined; may be ignored).
  final List<String> excludes;
}
