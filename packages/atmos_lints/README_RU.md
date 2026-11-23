# atmos_lints

English: [README.md](README.md).

Общие пресеты Dart analyzer / linter для пакетов [Atom735](https://github.com/Atom735).

Пакет содержит **только YAML-пресеты** (без runtime Dart API). Подключайте один
из них в `analysis_options.yaml`.

## Установка

```yaml
dev_dependencies:
  atmos_lints: ^1.2.0
```

```yaml
# analysis_options.yaml
include: package:atmos_lints/full_2.yaml
```

Рекомендуемый дефолт в этом монорепо: **`full_2.yaml`**.

## Пресеты

Два уровня строгости, у каждого базовый и ослабленный (`_2`) вариант:

| Include | Роль |
|---------|------|
| `package:atmos_lints/lints.yaml` | Базовый набор (~190 правил). Нормальный дефолт для библиотек. |
| `package:atmos_lints/lints_2.yaml` | Как `lints`, чуть мягче по стилю. |
| `package:atmos_lints/full.yaml` | Расширенный набор (~210 правил): больше современных проверок + `public_member_api_docs`. |
| `package:atmos_lints/full_2.yaml` | Как `full`, но многие style/doc правила ослаблены (меньше шума). |

### `lints` vs `full`

`full` добавляет более строгие / новые правила, которых нет в `lints`, например:

- `require_trailing_commas`
- `use_build_context_synchronously`
- `use_super_parameters` / `use_super_initializers`
- `discarded_futures`
- `unreachable_from_main`
- другие null-safety / Flutter-ориентированные проверки

Также отличается от `lints` по нескольким переключателям:

| Правило | `lints` | `full` |
|---------|---------|--------|
| `public_member_api_docs` | off | on |
| `prefer_expression_function_bodies` | on | off |
| `sort_constructors_first` | on | off |
| `always_put_required_named_parameters_first` | on | off |

### Что значит `_2`

`_2` — **ослабленная** редакция того же профиля (меньше шумных style-замечаний).

- `lints` → `lints_2`: выключает `always_put_required_named_parameters_first`, `sort_constructors_first`
- `full` → `full_2`: выключает больше style/docs правил (например `public_member_api_docs`, `discarded_futures`, `cascade_invocations`, `prefer_int_literals`, `use_super_parameters`, …) и слегка обновляет список правил

### Какой выбрать

| Цель | Пресет |
|------|--------|
| Повседневная работа над библиотекой | `lints.yaml` или `lints_2.yaml` |
| Строже + требовать docs у публичного API | `full.yaml` |
| Строже проверки, меньше style-шума | `full_2.yaml` |

## Ссылки

- [Linter changelog](https://pub.dev/packages/linter/changelog)
- [Полный список правил](https://dart-lang.github.io/linter/lints/)

## Лицензия

MIT — см. [LICENSE](LICENSE).
