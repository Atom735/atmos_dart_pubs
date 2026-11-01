import 'dart:typed_data';

import 'format.dart';

/// Failure while recognizing or parsing an image.
class ExecutableFormatException implements Exception {
  /// Creates a parse error.
  ExecutableFormatException(this.message);

  /// English explanation.
  final String message;

  @override
  String toString() => 'ExecutableFormatException: $message';
}

/// The image was recognized, but this version cannot edit it.
class ExecutableUnsupportedException extends ExecutableFormatException {
  /// Creates an unsupported-format error.
  ExecutableUnsupportedException(this.format, super.message);

  /// Detected container.
  final ExecutableFormat format;
}

/// A requested edit does not fit the image.
class ExecutableEditException implements Exception {
  /// Creates an edit error.
  ExecutableEditException(this.message);

  /// English explanation.
  final String message;

  @override
  String toString() => 'ExecutableEditException: $message';
}

/// One named slice of an executable (an ELF section or a PE section).
class ExecutableSection {
  /// Creates a section that aliases [image] at [fileOffset].
  ExecutableSection({
    required this.name,
    required this.virtualAddress,
    required this.virtualSize,
    required this.fileOffset,
    required this.fileSize,
    required this.flags,
    required Uint8List image,
  }) : _image = image;

  /// Section name. Empty for the ELF null section.
  final String name;

  /// Virtual address or RVA.
  final int virtualAddress;

  /// Size in memory.
  final int virtualSize;

  /// File offset of the raw bytes. Zero when the section has no file data.
  final int fileOffset;

  /// Raw size in the file.
  final int fileSize;

  /// ELF section flags or PE section characteristics.
  final int flags;

  final Uint8List _image;

  /// Copy of the raw bytes.
  Uint8List get bytes {
    if (fileSize == 0) return Uint8List(0);
    return Uint8List.fromList(
      Uint8List.sublistView(_image, fileOffset, fileOffset + fileSize),
    );
  }

  /// Replaces the raw bytes. [data] must be exactly [fileSize] long.
  ///
  /// Changing the size would move every later offset in the file. That
  /// rewrite is not part of this version.
  void writeBytes(List<int> data) {
    if (data.length != fileSize) {
      throw ExecutableEditException(
        'Section "$name" is $fileSize bytes. '
        'A replacement must have the same length.',
      );
    }
    if (fileSize == 0) return;
    _image.setRange(fileOffset, fileOffset + fileSize, data);
  }
}

/// A parsed executable that can be edited and written back.
abstract class ExecutableImage {
  /// Container kind.
  ExecutableFormat get format;

  /// ELF entry address, or PE address of the entry point (an RVA).
  int get entryPoint;

  /// Writes a new entry. The value must fit the header field.
  set entryPoint(int value);

  /// Sections in file order, including the ELF null section.
  List<ExecutableSection> get sections;

  /// First section with [name], or null.
  ExecutableSection? sectionByName(String name) {
    for (final section in sections) {
      if (section.name == name) return section;
    }
    return null;
  }

  /// Copy of the image, including edits.
  Uint8List toBytes();
}

/// Throws when [offset] and [size] do not fit in [length].
void requireInFile(int offset, int size, int length, String what) {
  if (offset < 0 || size < 0 || offset > length || size > length - offset) {
    throw ExecutableFormatException('$what is outside the file.');
  }
}
