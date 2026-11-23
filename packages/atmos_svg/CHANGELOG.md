# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

- Parse SVG into a mutable element tree (`SvgDocument` / `SvgElement`)
- Query by id, tag, and simple CSS selectors (`#id`, `tag`, `tag[attr]`)
- Edit attributes, children, text; clone and remove nodes
- Serialize back to XML (`toXml` / `toXmlString`)
- `SvgPath` parse / write / transform (`translate`, `scale`, `transform`)
- `SvgViewBox` helper for the root `viewBox` attribute
