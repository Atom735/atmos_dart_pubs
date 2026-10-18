import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// Whether the File System Access pickers appear to be available.
bool get isFileSystemAccessApiSupported {
  if (!jsInteropSupported) return false;
  return globalHasProperty('showOpenFilePicker') &&
      globalHasProperty('showDirectoryPicker');
}
