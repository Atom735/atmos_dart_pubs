# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

- Identify ELF, PE (`MZ`), and Mach-O
- Parse ELF32/ELF64 (either endian, including `e_shnum == 0`) and PE32/PE32+
- Edit the entry point
- Replace a section with bytes of the same length
- Mach-O is reported and not edited
