`# Points Hook

A Uniswap v4 hook that rewards users with ERC-1155 "points" for interacting with an
ETH-TOKEN pool — both for swapping ETH into TOKEN and for adding liquidity.

## How it works

`PointsHook` (in [`src/PointsHook.sol`](src/PointsHook.sol)) is a `BaseHook` that is also an
ERC-1155 token contract. Points are minted with `id == poolId`, so each pool this hook is
attached to gets its own points token.

- **`afterSwap`** — when a user buys TOKEN with ETH (a `zeroForOne` swap on an ETH/TOKEN
  pool), the hook mints points equal to 20% of the ETH spent.
- **`afterAddLiquidity`** — when a user adds liquidity to an ETH/TOKEN pool, the hook mints
  points equal to 20% of the ETH deposited.

In both cases:
- The pool must have `currency0` be the native ETH placeholder address (i.e. an ETH/TOKEN
  pool) — other pools are ignored.
- The recipient is read from `hookData`, which must ABI-encode a single `address`. If no
  `hookData` is passed, or it decodes to `address(0)`, no points are minted.

Known limitation: points minted for adding liquidity are not clawed back on
`afterRemoveLiquidity`, so liquidity can currently be added and withdrawn purely to farm
points.

## Project layout

```
src/PointsHook.sol   # the hook contract
test/                # Foundry tests (WIP)
script/              # deployment scripts (WIP)
```

## Usage

This is a [Foundry](https://book.getfoundry.sh/) project.

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```

### Gas snapshots

```shell
forge snapshot
```

### Local node

```shell
anvil
```

### Deploy

Because Uniswap v4 hook addresses must encode their permission flags, hooks can't be
deployed with a plain `forge create` — they need to be mined/deployed via `CREATE2` (e.g.
with `HookMiner`) so the resulting address has the right flag bits set. Add a deployment
script under `script/` that does this before deploying to a live network.

```shell
forge script script/<YourScript>.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```
