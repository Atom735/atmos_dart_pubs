import 'dart:typed_data';

import 'errors.dart';
import 'file_stat.dart';
import 'provider.dart';
import 'watch.dart';

/// High-level facade that routes URI schemes to registered providers.
class AtmosFileSystem {
  /// Creates an empty registry.
  AtmosFileSystem();

  final Map<String, FileSystemProvider> _providers = {};

  /// Registers [provider] for its [FileSystemProvider.scheme].
  void register(FileSystemProvider provider) {
    _providers[provider.scheme] = provider;
  }

  /// Removes the provider for [scheme], if any.
  void unregister(String scheme) {
    _providers.remove(scheme);
  }

  /// Provider for [uri], or throws.
  FileSystemProvider providerFor(Uri uri) {
    final provider = _providers[uri.scheme];
    if (provider == null) {
      throw FileSystemUnavailableException(
        'No provider registered for scheme "${uri.scheme}"',
        uri: uri,
      );
    }
    return provider;
  }

  /// Registered schemes.
  Iterable<String> get schemes => _providers.keys;

  /// See [FileSystemProvider.stat].
  Future<FileStat> stat(Uri uri) => providerFor(uri).stat(uri);

  /// See [FileSystemProvider.createDirectory].
  Future<void> createDirectory(Uri uri) =>
      providerFor(uri).createDirectory(uri);

  /// See [FileSystemProvider.readDirectory].
  Future<List<(String name, int type)>> readDirectory(Uri uri) =>
      providerFor(uri).readDirectory(uri);

  /// See [FileSystemProvider.delete].
  Future<void> delete(
    Uri uri, {
    bool recursive = false,
    bool useTrash = false,
    bool atomic = false,
  }) {
    return providerFor(uri).delete(
      uri,
      FileDeleteOptions(
        recursive: recursive,
        useTrash: useTrash,
        atomic: atomic,
      ),
    );
  }

  /// See [FileSystemProvider.rename].
  Future<void> rename(Uri from, Uri to, {bool overwrite = false}) {
    return providerFor(from).rename(
      from,
      to,
      FileOverwriteOptions(overwrite: overwrite),
    );
  }

  /// See [FileSystemProvider.copy].
  Future<void> copy(Uri from, Uri to, {bool overwrite = false}) {
    return providerFor(from).copy(
      from,
      to,
      FileOverwriteOptions(overwrite: overwrite),
    );
  }

  /// See [FileSystemProvider.readFile].
  Future<Uint8List> readFile(Uri uri) => providerFor(uri).readFile(uri);

  /// See [FileSystemProvider.writeFile].
  Future<void> writeFile(
    Uri uri,
    Uint8List content, {
    bool create = true,
    bool overwrite = true,
    bool unlock = false,
    bool atomic = false,
  }) {
    return providerFor(uri).writeFile(
      uri,
      content,
      FileWriteOptions(
        create: create,
        overwrite: overwrite,
        unlock: unlock,
        atomic: atomic,
      ),
    );
  }

  /// See [FileSystemProvider.watch].
  FileSystemWatchSubscription watch(
    Uri uri, {
    bool recursive = false,
    List<String> excludes = const [],
  }) {
    return providerFor(uri).watch(
      uri,
      WatchOptions(recursive: recursive, excludes: excludes),
    );
  }
}
