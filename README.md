# atmos_dart_pubs

Monorepo for public Flutter and Dart packages by [Atom735](https://github.com/Atom735).

## Layout

```text
packages/
  <package_name>/   # one pub package per folder
```

Each package under `packages/` is published independently to [pub.dev](https://pub.dev).

## Packages

| Package | Description | pub.dev |
|---------|-------------|---------|
| *(none yet)* | — | — |

## Development

```bash
# From a package directory
cd packages/<package_name>
dart pub get
# or
flutter pub get
```

Optional: [Melos](https://pub.dev/packages/melos) can manage all packages from the repo root (`melos.yaml`).

## License

Unless noted otherwise in a package, code is under the BSD 3-Clause License. See [LICENSE](LICENSE).
