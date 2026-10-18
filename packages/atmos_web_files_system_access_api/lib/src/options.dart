import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// Accept types for open/save pickers (`accept` map: MIME → extensions).
class FilePickerAcceptType {
  /// Creates an accept type entry.
  const FilePickerAcceptType({this.description, required this.accept});

  /// Optional UI description.
  final String? description;

  /// Map of MIME type → list of extensions (e.g. `text/plain` → `['.txt']`).
  final Map<String, List<String>> accept;

  /// Converts to a plain JS object for the picker.
  Object toJs() {
    final acceptJs = jsNewObject();
    accept.forEach((mime, exts) {
      // FSA expects a real JS Array of extensions, not a Dart List.
      jsSetProperty(acceptJs, mime, jsArray(exts));
    });
    final out = jsNewObject();
    if (description != null) {
      jsSetProperty(out, 'description', description);
    }
    jsSetProperty(out, 'accept', acceptJs);
    return out;
  }
}

/// Options for `showOpenFilePicker`.
class OpenFilePickerOptions {
  /// Creates open-picker options.
  const OpenFilePickerOptions({
    this.multiple = false,
    this.excludeAcceptAllOption = false,
    this.types = const [],
    this.id,
    this.startIn,
  });

  /// Allow selecting multiple files.
  final bool multiple;

  /// Hide the “all files” filter.
  final bool excludeAcceptAllOption;

  /// Accept filters.
  final List<FilePickerAcceptType> types;

  /// Remembers last directory for this id.
  final String? id;

  /// Well-known start directory id, or a handle object.
  final Object? startIn;

  /// Converts to a plain JS object.
  Object toJs() {
    final out = jsNewObject();
    jsSetProperty(out, 'multiple', multiple);
    jsSetProperty(out, 'excludeAcceptAllOption', excludeAcceptAllOption);
    if (types.isNotEmpty) {
      jsSetProperty(out, 'types', jsArray(types.map((t) => t.toJs())));
    }
    if (id != null) jsSetProperty(out, 'id', id);
    if (startIn != null) jsSetProperty(out, 'startIn', startIn);
    return out;
  }
}

/// Options for `showSaveFilePicker`.
class SaveFilePickerOptions {
  /// Creates save-picker options.
  const SaveFilePickerOptions({
    this.excludeAcceptAllOption = false,
    this.types = const [],
    this.suggestedName,
    this.id,
    this.startIn,
  });

  /// Hide the “all files” filter.
  final bool excludeAcceptAllOption;

  /// Accept filters.
  final List<FilePickerAcceptType> types;

  /// Suggested file name.
  final String? suggestedName;

  /// Remembers last directory for this id.
  final String? id;

  /// Well-known start directory id, or a handle object.
  final Object? startIn;

  /// Converts to a plain JS object.
  Object toJs() {
    final out = jsNewObject();
    jsSetProperty(out, 'excludeAcceptAllOption', excludeAcceptAllOption);
    if (types.isNotEmpty) {
      jsSetProperty(out, 'types', jsArray(types.map((t) => t.toJs())));
    }
    if (suggestedName != null) {
      jsSetProperty(out, 'suggestedName', suggestedName);
    }
    if (id != null) jsSetProperty(out, 'id', id);
    if (startIn != null) jsSetProperty(out, 'startIn', startIn);
    return out;
  }
}

/// Options for `showDirectoryPicker`.
class DirectoryPickerOptions {
  /// Creates directory-picker options.
  const DirectoryPickerOptions({
    this.id,
    this.mode = 'read',
    this.startIn,
  });

  /// Remembers last directory for this id.
  final String? id;

  /// `'read'` or `'readwrite'`.
  final String mode;

  /// Well-known start directory id, or a handle object.
  final Object? startIn;

  /// Converts to a plain JS object.
  Object toJs() {
    final out = jsNewObject();
    jsSetProperty(out, 'mode', mode);
    if (id != null) jsSetProperty(out, 'id', id);
    if (startIn != null) jsSetProperty(out, 'startIn', startIn);
    return out;
  }
}

/// Options for `getFileHandle` / `getDirectoryHandle`.
class GetHandleOptions {
  /// Creates get-handle options.
  const GetHandleOptions({this.create = false});

  /// Create the entry if missing.
  final bool create;

  /// Converts to a plain JS object.
  Object toJs() {
    final out = jsNewObject();
    jsSetProperty(out, 'create', create);
    return out;
  }
}

/// Options for `removeEntry`.
class RemoveEntryOptions {
  /// Creates remove options.
  const RemoveEntryOptions({this.recursive = false});

  /// Remove non-empty directories.
  final bool recursive;

  /// Converts to a plain JS object.
  Object toJs() {
    final out = jsNewObject();
    jsSetProperty(out, 'recursive', recursive);
    return out;
  }
}

/// Options for permission `query` / `request`.
class FileSystemHandlePermissionDescriptor {
  /// Creates a permission descriptor.
  const FileSystemHandlePermissionDescriptor({this.mode = 'read'});

  /// `'read'` or `'readwrite'`.
  final String mode;

  /// Converts to a plain JS object.
  Object toJs() {
    final out = jsNewObject();
    jsSetProperty(out, 'mode', mode);
    return out;
  }
}
