# atmos_vsc_codicon_flutter

VS Code **Codicon** product icons for Flutter by
[Atom735](https://github.com/Atom735). No Material or Cupertino.

Русский: [README_RU.md](README_RU.md).

- Bundled `assets/codicon.ttf` (family `codicon`)
- Full product-icon map from
  [vscode-codicons](https://github.com/microsoft/vscode-codicons):
  **766** ids, **659** code points, font **1.15**
- `VscCodicons`, `VscCodicon` / `VscCodicon.fromRef`, `VscCodiconCatalog`
- Upstream submodule
  [`third_party/vscode-codicons`](third_party/vscode-codicons)

## Install

```yaml
dependencies:
  atmos_vsc_codicon_flutter: ^0.0.1-alpha
```

The package registers the font. An app should not declare `codicon` again.

## Quick start

```dart
import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

const icon = VscCodicon(VscCodicons.book);

final fromCommand = VscCodicon.fromRef(r'$(git-pull-request)');
final info = VscCodiconCatalog.find(r'$(git-pull-request)');
// info?.dartName == 'gitPullRequest'
// info?.category == 'git'
```

`fromRef`, `resolve`, and `find` accept `git-pull-request`,
`$(git-pull-request)`, `codicon-search`, and the camelCase Dart name
(`gitPullRequest`). `namesFor` lists every alias of a code point.
`categories` is the upstream category list.

`VscCodicons` holds only `static const` values, so a release build can drop
code points that the app never mentions. Using `VscCodiconCatalog` keeps every
glyph, which is what a command-icon lookup needs.

## Preview

```bash
cd packages/atmos_vsc_codicon_flutter/example
flutter pub get
flutter run -d chrome
```

Search by id, code point, description, or category. **Primary** hides
aliases (`plus` for `add`). **All** shows every name. The category strip
filters by the primary glyph's category. The detail pane copies the Dart
member, `$(id)`, and the code point.

## Updating from upstream

Consumers do not need the submodule. The built font and generated Dart are
committed in this package. To refresh them:

```bash
git submodule update --init --recursive
git -C packages/atmos_vsc_codicon_flutter/third_party/vscode-codicons pull
cd packages/atmos_vsc_codicon_flutter/third_party/vscode-codicons
mkdir -p dist
npm ci
npm run fonts
cd ../../..
dart run tool/generate_codicons.dart
dart format lib test tool
```

`npm run fonts` is the upstream Fantasticon build and needs **Node.js 22+**.
`mkdir dist` matters on Windows: Fantasticon does not create that directory.

## License

Dart code is MIT. See [LICENSE](LICENSE).

The font is **CC-BY-4.0**, Microsoft Corporation. See [NOTICE.md](NOTICE.md).
