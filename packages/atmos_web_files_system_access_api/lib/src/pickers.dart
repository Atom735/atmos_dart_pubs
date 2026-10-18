import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';
import 'handles.dart';
import 'options.dart';
import 'support.dart';

Future<T> _callPicker<T>(
  String globalName,
  Object? options,
  T Function(Object js) map,
) async {
  if (!isFileSystemAccessApiSupported) {
    throw FileSystemAccessException(
      'File System Access API is not available in this runtime',
    );
  }
  if (!globalHasProperty(globalName)) {
    throw FileSystemAccessException('$globalName is missing');
  }
  try {
    final args = options == null ? const <Object?>[] : <Object?>[options];
    final result = jsCallMethod<Object>(jsGlobalThis, globalName, args);
    final value = await jsMaybePromiseToFuture<Object>(result);
    return map(value);
  } on Object catch (e) {
    final name = _errorName(e);
    if (name == 'AbortError') {
      throw FileSystemAccessAbortException();
    }
    throw FileSystemAccessException('Picker $globalName failed', cause: e);
  }
}

String? _errorName(Object error) {
  try {
    return jsGetProperty<String?>(error, 'name');
  } on Object {
    return null;
  }
}

/// Shows the open-file picker; returns one or more file handles.
Future<List<FileSystemFileHandle>> showOpenFilePicker([
  OpenFilePickerOptions? options,
]) {
  return _callPicker(
    'showOpenFilePicker',
    options?.toJs(),
    (js) {
      final length = jsGetProperty<Object?>(js, 'length');
      final len = length is num ? length.toInt() : 0;
      return [
        for (var i = 0; i < len; i++)
          FileSystemFileHandle(jsGetProperty<Object>(js, i)),
      ];
    },
  );
}

/// Shows the save-file picker; returns a single file handle.
Future<FileSystemFileHandle> showSaveFilePicker([
  SaveFilePickerOptions? options,
]) {
  return _callPicker(
    'showSaveFilePicker',
    options?.toJs(),
    FileSystemFileHandle.new,
  );
}

/// Shows the directory picker; returns a directory handle.
Future<FileSystemDirectoryHandle> showDirectoryPicker([
  DirectoryPickerOptions? options,
]) {
  return _callPicker(
    'showDirectoryPicker',
    options?.toJs(),
    FileSystemDirectoryHandle.new,
  );
}
