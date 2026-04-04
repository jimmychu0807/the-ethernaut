# AGENTS.md

## Cursor Cloud specific instructions

This is a Solidity/Foundry project containing Ethernaut wargame solutions and Yul/Assembly exercises.

### Toolchain

- **Foundry** (`forge`, `anvil`, `cast`, `chisel`) — primary Solidity toolchain. CI runs `forge fmt --check`, `forge build`, `forge test -vvv`.
- **pnpm** + Node.js — used only for TypeScript helper scripts (challenge #37). `pnpm build` runs `tsc` (type-check only, `noEmit: true`).

### Solc binary installation (egress caveat)

`binaries.soliditylang.org` is blocked in Cloud Agent VMs. Forge cannot auto-download solc. The update script pre-installs required solc versions from GitHub releases into `~/.svm/`. If a new solc version is needed, download it similarly:

```
mkdir -p ~/.svm/<version>
curl -L -o ~/.svm/<version>/solc-<version> \
  "https://github.com/argotorg/solidity/releases/download/v<version>/solc-static-linux"
chmod +x ~/.svm/<version>/solc-<version>
```

### Running services

- `forge test -vvv` — runs all Solidity tests (no external services needed).
- `forge fmt --check` — lint/format check.
- `forge build` — compile all contracts.
- `pnpm build` — TypeScript type-check. Note: there is a pre-existing `TS6133` error in `customKSigner.ts` (unused variable).

### Git submodules

Solidity library dependencies live in `lib/` as git submodules. Run `git submodule update --init --recursive` after cloning.
