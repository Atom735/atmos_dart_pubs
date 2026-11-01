# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

- Disassemble x86-32 and x86-64 in Intel syntax
- Linear sweep that stops at the first undecoded byte
- Calls, jumps, memory operands (including RIP-relative), `lock` / `rep`
- SSE, AVX, and x87 are not decoded
