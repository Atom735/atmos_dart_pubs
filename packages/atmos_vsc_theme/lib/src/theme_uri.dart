/// Directory URI of [fileUri], with a trailing slash.
///
/// Used so nested `include` paths resolve against each theme file.
Uri themeDirectoryUri(Uri fileUri) {
  final path = fileUri.path;
  final i = path.lastIndexOf('/');
  if (i <= 0) {
    return fileUri.replace(path: '/');
  }
  return fileUri.replace(path: path.substring(0, i + 1));
}
