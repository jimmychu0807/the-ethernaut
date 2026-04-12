# Ethernaut Solutions (Foundry)

This repository is a Solidity-first workspace for solving OpenZeppelin Ethernaut levels with reproducible tests, scripts, and supporting research notes.

## What This Repository Contains

- Numbered challenge folders in [`src/`](./src) with vulnerable contracts, solver contracts, tests (`*.t.sol`), and deployment/automation scripts (`*.s.sol`) where relevant.
- TypeScript helpers in [`src/ts/`](./src/ts) for specific challenges (currently challenge 37).
- Yul and Assembly practice exercises in [`src/yul-course/`](./src/yul-course).
- Long-form walkthrough notes and onchain execution logs in [`solutions.md`](./solutions.md).

## Repository Layout

- [`src/`](./src): Ethernaut challenge implementations and solutions.
- [`src/helpers/`](./src/helpers): shared utilities used by advanced exercises.
- [`src/ts/`](./src/ts): TypeScript-based helper scripts.
- [`lib/`](./lib): Git submodules (OpenZeppelin versions + Forge Std dependencies).

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- `git`
- Node.js and `pnpm` (repo pins `pnpm@10.27.0` in `package.json`)

## Getting Started

```bash
git clone https://github.com/<your-org-or-user>/ethernaut.git
cd ethernaut
git submodule update --init --recursive
forge build
forge test -vvv
```

## Quality Checks and CI

CI runs the following checks:

- `forge fmt --check`
- `forge build --sizes`
- `forge test -vvv`

You can run the same commands locally before opening a PR.

## TypeScript Workflow (Challenge 37)

```bash
pnpm install
pnpm build
pnpm run 37
```

Notes:
- `pnpm build` runs TypeScript type-checking only (`noEmit: true`).
- There is a known `TS6133` (unused variable) note in `customKSigner.ts`.

## Compiler and EVM Settings

Project defaults are defined in [`foundry.toml`](./foundry.toml), including:

- optimizer enabled (`optimizer_runs = 200`)
- `evm_version = "prague"`
- remappings for OpenZeppelin and Forge Std submodules

## Links

- Ethernaut problem set: [https://ethernaut.openzeppelin.com/](https://ethernaut.openzeppelin.com/)
- Repo walkthrough notes: [`solutions.md`](./solutions.md)
- Yul course reference: [Udemy Advanced Solidity: Yul and Assembly](https://www.udemy.com/course/advanced-solidity-yul-and-assembly)
- Yul exercises folder: [`src/yul-course/`](./src/yul-course)
- Maintainer automation notes: [`AGENTS.md`](./AGENTS.md)

## Remaining Levels / Follow-ups

- Level 25 (Motorbike): upstream context in [OpenZeppelin/ethernaut issue #701](https://github.com/OpenZeppelin/ethernaut/issues/701)
- Level 40 (NotOptimisticPortal): currently tracked as remaining/in-progress in this repo

## Security and Usage Disclaimer

This repository is for security education and CTF-style practice. Some code demonstrates exploit patterns and intentionally vulnerable designs. Do not treat these solutions as production-ready smart contract patterns.

## License

MIT. See [`LICENSE`](./LICENSE).
