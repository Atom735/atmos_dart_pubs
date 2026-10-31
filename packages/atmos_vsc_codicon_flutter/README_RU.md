# atmos_vsc_codicon_flutter

Product icons **Codicon** из VS Code для Flutter,
[Atom735](https://github.com/Atom735). Без Material и Cupertino.

English: [README.md](README.md).

- Шрифт `assets/codicon.ttf` (семейство `codicon`)
- Полная таблица product icons из
  [vscode-codicons](https://github.com/microsoft/vscode-codicons):
  **766** id, **659** кодпоинтов, шрифт **1.15**
- `VscCodicons`, `VscCodicon` / `VscCodicon.fromRef`, `VscCodiconCatalog`
- Сабмодуль upstream
  [`third_party/vscode-codicons`](third_party/vscode-codicons)

## Установка

```yaml
dependencies:
  atmos_vsc_codicon_flutter: ^0.0.1-alpha
```

Шрифт регистрирует пакет. В приложении `codicon` объявлять не нужно.

## Быстрый старт

```dart
import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

const icon = VscCodicon(VscCodicons.book);

final fromCommand = VscCodicon.fromRef(r'$(git-pull-request)');
final info = VscCodiconCatalog.find(r'$(git-pull-request)');
// info?.dartName == 'gitPullRequest'
```

`fromRef`, `resolve` и `find` понимают `git-pull-request`,
`$(git-pull-request)`, `codicon-search` и camelCase-имя Dart
(`gitPullRequest`). `namesFor` перечисляет алиасы кодпоинта.
`categories` — список категорий upstream.

В `VscCodicons` только `static const`, поэтому release-сборка может выкинуть
кодпоинты, которые приложение не упоминает. Обращение к `VscCodiconCatalog`
оставляет все глифы — это нужно, чтобы резолвить иконку команды по строке.

## Превью

```bash
cd packages/atmos_vsc_codicon_flutter/example
flutter pub get
flutter run -d chrome
```

Поиск по id, кодпоинту, описанию или категории. **Primary** прячет алиасы
(`plus` у `add`). **All** показывает каждое имя. Полоса категорий фильтрует
по категории первичного глифа. В панели справа копируются имя Dart, `$(id)`
и кодпоинт.

## Обновление из upstream

Потребителям пакета сабмодуль не нужен: собранный шрифт и сгенерированный Dart
лежат в пакете. Чтобы обновить их:

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

`npm run fonts` — сборка Fantasticon из upstream, нужен **Node.js 22+**.
`mkdir dist` нужен на Windows: Fantasticon сам каталог не создаёт.

## Лицензия

Код Dart — MIT. См. [LICENSE](LICENSE).

Шрифт — **CC-BY-4.0**, Microsoft Corporation. См. [NOTICE.md](NOTICE.md).
