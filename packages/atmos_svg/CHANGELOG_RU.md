# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.0

- Разбор SVG в изменяемое дерево элементов (`SvgDocument` / `SvgElement`)
- Поиск по id, тегу и простым CSS-селекторам (`#id`, `tag`, `tag[attr]`)
- Редактирование атрибутов, детей, текста; clone и remove
- Сериализация обратно в XML (`toXml` / `toXmlString`)
- `SvgPath`: разбор / запись / трансформации (`translate`, `scale`, `transform`)
- Хелпер `SvgViewBox` для корневого атрибута `viewBox`
