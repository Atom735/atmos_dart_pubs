/// Target OS for default keybinding dumps / platform key overrides.
enum VscKeyPlatform {
  /// Windows defaults (`windows.keybindings.json`).
  windows,

  /// macOS defaults (`macos.keybindings.json`).
  macos,

  /// Linux defaults (`linux.keybindings.json`).
  linux,
}

/// Helpers for [VscKeyPlatform].
extension VscKeyPlatformX on VscKeyPlatform {
  /// Asset / dump file name without directory.
  String get fileName {
    switch (this) {
      case VscKeyPlatform.windows:
        return 'windows.keybindings.json';
      case VscKeyPlatform.macos:
        return 'macos.keybindings.json';
      case VscKeyPlatform.linux:
        return 'linux.keybindings.json';
    }
  }

  /// Negative dump that clears OS defaults
  /// (`windows.negative.keybindings.json`).
  String get negativeFileName {
    switch (this) {
      case VscKeyPlatform.windows:
        return 'windows.negative.keybindings.json';
      case VscKeyPlatform.macos:
        return 'macos.negative.keybindings.json';
      case VscKeyPlatform.linux:
        return 'linux.negative.keybindings.json';
    }
  }

  /// Short id used by `VscKeybinding.keyForPlatform`.
  String get id {
    switch (this) {
      case VscKeyPlatform.windows:
        return 'windows';
      case VscKeyPlatform.macos:
        return 'macos';
      case VscKeyPlatform.linux:
        return 'linux';
    }
  }
}
