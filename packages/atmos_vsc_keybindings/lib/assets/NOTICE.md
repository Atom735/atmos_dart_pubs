# Bundled default keybindings

JSON is provided by the git submodule
[`lib/assets/vs-code-default-keybindings`](vs-code-default-keybindings/),
cloned from
[codebling/vs-code-default-keybindings](https://github.com/codebling/vs-code-default-keybindings)
(currently VS Code **1.144.0** headers).

- Upstream dumps: community project derived from VS Code defaults
- VS Code sources: [MIT](https://github.com/microsoft/vscode/blob/main/LICENSE.txt)

```bash
# clone / update
git submodule update --init --recursive
# bump dumps
git -C packages/atmos_vsc_keybindings/lib/assets/vs-code-default-keybindings pull
# then bump VscBundledKeybindings.vscodeVersion if the header changed
```
