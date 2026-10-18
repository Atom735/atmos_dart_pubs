# atmos_lints

Shared Dart analyzer / linter presets for [Atom735](https://github.com/Atom735) packages.

This package ships **YAML presets only** (no runtime Dart API). Include one of them from `analysis_options.yaml`.

## Install

```yaml
dev_dependencies:
  atmos_lints: ^1.2.0
```

```yaml
# analysis_options.yaml
include: package:atmos_lints/full_2.yaml
```

Recommended default in this monorepo: **`full_2.yaml`**.

## Presets

Two strictness levels, each with a base and a relaxed (`_2`) variant:

| Include | Role |
|---------|------|
| `package:atmos_lints/lints.yaml` | Base set (~190 rules). Solid default for libraries. |
| `package:atmos_lints/lints_2.yaml` | Same as `lints`, slightly looser on style. |
| `package:atmos_lints/full.yaml` | Extended set (~210 rules): more modern checks + `public_member_api_docs`. |
| `package:atmos_lints/full_2.yaml` | Like `full`, but many stylistic/doc rules relaxed (less noise). |

### `lints` vs `full`

`full` adds stricter / newer rules that are not in `lints`, for example:

- `require_trailing_commas`
- `use_build_context_synchronously`
- `use_super_parameters` / `use_super_initializers`
- `discarded_futures`
- `unreachable_from_main`
- other null-safety / Flutter-oriented checks

Also differs from `lints` on a few toggles:

| Rule | `lints` | `full` |
|------|---------|--------|
| `public_member_api_docs` | off | on |
| `prefer_expression_function_bodies` | on | off |
| `sort_constructors_first` | on | off |
| `always_put_required_named_parameters_first` | on | off |

### What `_2` means

`_2` is a **relaxed** edition of the same profile (fewer noisy style findings).

- `lints` → `lints_2`: turns off `always_put_required_named_parameters_first`, `sort_constructors_first`
- `full` → `full_2`: turns off more style/docs rules (e.g. `public_member_api_docs`, `discarded_futures`, `cascade_invocations`, `prefer_int_literals`, `use_super_parameters`, …) and slightly refreshes the rule list

### Which one to pick

| Goal | Preset |
|------|--------|
| Everyday library work | `lints.yaml` or `lints_2.yaml` |
| Stricter + require public API docs | `full.yaml` |
| Stricter checks, less style noise | `full_2.yaml` |

## References

- [Linter changelog](https://pub.dev/packages/linter/changelog)
- [Complete rule list](https://dart-lang.github.io/linter/lints/)

## License

MIT — see [LICENSE](LICENSE).
