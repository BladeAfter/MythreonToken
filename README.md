# MYTHREON TOKEN

Independent smart-contract project for the official Mythreon ecosystem token.
This repository contains no game, Supabase, Telegram, marketplace, internal
wallet, Clan War, NFT Mining, or frontend integration.

**Current checkpoint:** source prepared for local validation; **not deployed**.
The official Jetton Master address does not exist yet and must remain recorded
as `NOT DEPLOYED` until an authorized testnet transaction succeeds.

| Property | Value |
|---|---|
| Name | Mythreon Token |
| Symbol | MYTH |
| Blockchain | TON |
| Network | Testnet only |
| Standard | TEP-74 Jetton |
| Implementation | TON Acton Jetton v2.1 |
| Language | Tolk |
| Toolchain | Acton trunk, matching the pinned Jetton v2.1 source |
| Decimals | 9 |
| Planned final supply | 100,000,000 MYTH |
| Initial supply at deploy | 0 MYTH |
| Mint authority | Enabled until a future explicit decision |
| Jetton Master | **NOT DEPLOYED** |

## Architecture and provenance

TON Jettons use one Master/Minter contract for supply and metadata and one
deterministically derived Jetton Wallet contract per holder. This project uses
the official reference-grade `jetton-v2.1` Tolk package from
`ton-blockchain/acton-contracts` at commit
`7af1cea3cd0b990ae7b53a67b858c8cbd9da1e16`. The upstream source implements
`get_jetton_data`, `get_wallet_address`, transfer, transfer notification, burn,
admin-only mint, two-step admin handoff, metadata update, and upgrade behavior.

The contract code is not customized. MYTH-specific behavior is confined to
initial storage/metadata, exact-unit helpers, tests, and guarded scripts. See
`THIRD_PARTY_NOTICES.md` and the included MIT license.

Standards:

- [TEP-74 — Fungible tokens (Jettons)](https://github.com/ton-blockchain/TEPs/blob/master/text/0074-jettons-standard.md)
- [TEP-89 — Jetton wallet discovery](https://github.com/ton-blockchain/TEPs/blob/master/text/0089-jetton-wallet-discovery.md)
- [TEP-64 — Token data/metadata](https://github.com/ton-blockchain/TEPs/blob/master/text/0064-token-data-standard.md)

## Requirements

- Node.js 20 or newer (helpers and launch guards).
- Acton `trunk` on supported Linux/macOS, matching the toolchain declared by
  the pinned official `acton-contracts/jetton-v2.1` source. Native Windows is
  not supported by Acton; use Ubuntu 22+ in WSL, Docker, or the included Ubuntu
  GitHub Actions job. `trunk` is a preview toolchain, so the upstream commit is
  pinned and CI is the release gate.
- No npm runtime dependencies are required.

Install Acton from its official release, then verify it:

```sh
curl -LsSf https://github.com/ton-blockchain/acton/releases/latest/download/acton-installer.sh | sh
acton up --trunk
acton --version
npm ci
```

## Build, tests, and lint

```sh
npm run build
npm test
npm run lint
# all gates in order:
npm run check
```

`npm test` runs the exact-unit Node tests and all Acton contract tests. The
suite includes the upstream Jetton v2.1 tests plus MYTH-specific cases for
9-decimal conversion, 10 MYTH transfer, notification, 100/10 MYTH burn, and
wallet derivation. The upstream suite covers unauthorized mint/admin changes,
invalid sender/wallet, malformed payloads, over-transfer, over-burn, bounce
accounting, discovery, gas/state bounds, and governance flows.

The standard does not treat repeated `query_id` values as duplicate-operation
rejection; it is a correlation field. Custom replay state was deliberately not
added. See `docs/SECURITY_REVIEW.md`.

CI performs install, build, tests, project checks, Acton lint, and formatting.
It contains no deployment job and no wallet secret.

## Exact amounts

`src/units.mjs` exposes `toMythUnits()` and `fromMythUnits()` using only decimal
strings and `bigint`. Financial amounts must never use `Number`, `parseFloat`,
or floating point as the final representation.

```js
toMythUnits('1')     // 1000000000n
toMythUnits('0.1')   // 100000000n
toMythUnits('0.001') // 1000000n
```

One MYTH equals 10^9 base units. The planned supply equals
`100000000000000000` base units. This is planning, not an on-chain cap; the
official contract remains mintable while an admin exists.

## Metadata

Deployment builds TEP-64 compatible on-chain metadata:

```text
name        Mythreon Token
symbol      MYTH
decimals    9
description The official ecosystem token of Mythreon.
image       https://assets.example.invalid/mythreon/myth-token.png
```

The owner-supplied source artwork is stored at `metadata/myth-token-icon.png`.
The wallet-safe adaptation used by the token metadata is
`metadata/myth-token-icon-wallet.png`; it preserves the approved dragon and
gold Mythreon M while filling the square corners and adding safe framing for
circular wallet crops. The on-chain image field remains an HTTPS placeholder
using the reserved `.invalid` domain because TON wallets cannot resolve a
repository path. Publish the exact wallet-safe asset at a durable HTTPS or IPFS
location and replace `JETTON_IMAGE` before deployment; localhost and Lovable
URLs are rejected by project checks. A matching external representation is in
`metadata/jetton.json`.

## Testnet configuration

Copy `.env.example` to `.env` and set public values only:

```dotenv
TON_NETWORK=testnet
ALLOW_MAINNET_DEPLOY=false
OWNER_ADDRESS=EQ...
JETTON_MINTER_ADDRESS=EQ...
RPC_ENDPOINT=https://testnet.toncenter.com/api/v2/jsonRPC
JETTON_IMAGE=https://durable.example/myth.png
```

`.env` is ignored. Never add a mnemonic, seed phrase, or private key. The
launcher defaults to Acton `--tonconnect`, so signing happens in an external
wallet. `OWNER_ADDRESS` is the public administrative address and may differ
from the wallet paying deployment fees.

Acton uses its built-in testnet network configuration. If rate limits require
an API key, set `TONCENTER_TESTNET_API_KEY` only in your local process/secret
store; never commit it. `RPC_ENDPOINT` documents the intended endpoint and is
reserved for a future reviewed custom-network configuration.

## Deployment — testnet only, not authorized yet

First emulate the deployment without broadcast:

```sh
TON_NETWORK=testnet acton script scripts/deploy.tolk
```

Only after code review and explicit authorization, run:

```sh
npm run deploy:testnet
```

Before the signer opens, the launcher prints network, name, symbol, decimals,
admin, initial mint, and estimated TON requirement, then requires typing
`TESTNET`. The Tolk script prints the values again and asks for confirmation.
It deploys with zero supply and prints:

```text
JETTON MASTER ADDRESS=EQ...
```

Record that exact testnet Master address as the MYTH identity. Never trust only
name, symbol, image, or a Jetton Wallet address.

The Node guard rejects mainnet when `ALLOW_MAINNET_DEPLOY=false`. A second
phase lock also rejects mainnet when the flag is `true`; removing that lock is
a future reviewed code change. Tolk operation scripts independently require
`TON_NETWORK=testnet`.

## Testnet operations after deployment

Set `JETTON_MINTER_ADDRESS` to the printed Master address.

Mint 1,000 MYTH (default), then query total supply and recipient balance:

```sh
npm run mint:testnet
# override safely with a decimal string:
MINT_AMOUNT_MYTH=1000 npm run mint:testnet
```

Transfer 10 MYTH (default) and print both wallet balances:

```sh
npm run transfer:testnet
```

The script prompts for the sender wallet and recipient public TON address. It
sends a positive forward amount so TEP-74 transfer notification is emitted.

Burn 10 MYTH (default) and re-query holder balance and total supply:

```sh
npm run burn:testnet
```

Verify Master state and metadata:

```sh
npm run verify:testnet
```

The output contains token, symbol, decimals, total supply, mintable flag, admin,
Master, network, and `Metadata: OK` or `INVALID`.

Derive and validate a holder's canonical MYTH Wallet through the Master getter:

```sh
npm run wallet:testnet
```

This calls on-chain `get_wallet_address`; it does not invent or trust an
unvalidated local address.

## Burn and transfer notification

Burn is initiated by the holder through their canonical Jetton Wallet. The
wallet checks owner and balance, debits, and sends a validated burn notification
to the Master; the Master reduces total supply. Bounce handling restores the
wallet balance if the notification fails.

For a transfer with `forward_ton_amount > 0`, the recipient Jetton Wallet emits
the TEP-74 `transfer_notification` to the recipient owner and preserves the
forward payload. A zero forward amount produces no notification. Future
Mythreon deposit infrastructure must validate the notification's wallet against
the official Master and must not trust symbol/name.

## Admin and mint authority

Deployment does not change or revoke authority. The intended sequence is:

1. Deploy on testnet with zero initial supply.
2. Mint an explicitly authorized amount.
3. Verify Master total supply and recipient balances.
4. Rehearse/document allocations without automatic distribution.
5. Decide separately whether to transfer admin to a multisig or drop it.

Admin transfer is two-step: current Admin A proposes Admin B with
`scripts/change-admin.tolk`; Admin B separately claims with
`scripts/claim-admin.tolk`. Tests prove A loses authority after B claims and B
can administer.

Future mint revocation uses the official `DropMinterAdmin` message, which sets
admin to null and makes `mintable=false`. It is irreversible in this
implementation. No npm command exposes it and deployment never invokes it.

## Tokenomics and value

Planned allocations are documented in `docs/TOKENOMICS.md`; no wallets are
created and nothing is distributed in this phase. The contract contains no USD
price, TON price, fixed market value, guaranteed value, or APY.

## Future mainnet process

Mainnet is out of scope. A later release must repeat current official-doc review,
pin and audit dependencies, run all gates on supported Acton, deploy/rehearse on
testnet, replace the image placeholder, establish multisig/key custody, review
compiled code hashes and authority policy, add a distinct manual confirmation,
and obtain explicit approval. There must never be push-to-mainnet automation.

See `SECURITY.md` and `docs/SECURITY_REVIEW.md` before any signing operation.
