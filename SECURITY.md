# Security policy

This repository is testnet-only. The contracts are the TON reference Jetton
v2.1 implementation; project additions are limited to metadata, tests, and
operational tooling. Report suspected vulnerabilities privately to the
Mythreon security contact before public disclosure.

## Never

- Never share a mnemonic or seed phrase.
- Never commit a private key, mnemonic, `.env`, `wallets.toml`, or signer session.
- Never put signing secrets in a frontend, Mini App, bot, CI variable used by a
  pull request, or browser bundle.
- Never run a mainnet script without a separate review, bytecode verification,
  rehearsed testnet procedure, multisig/key-custody plan, and explicit approval.
- Never revoke admin/mint authority prematurely. `DropMinterAdmin` is
  irreversible for this implementation.
- Never identify MYTH by name, symbol, or image. Trust the reviewed Jetton Master
  address for the intended network.

## Key handling

The preferred testnet signing flow is Acton with `--tonconnect`, so approval
happens in an external wallet and no mnemonic enters this repository. If an
Acton-managed development wallet is used instead, require OS keyring storage
with `acton wallet new --secure true`; do not use plaintext mnemonic sources.
The externally configured `OWNER_ADDRESS` is public and is safe to place in a
local `.env`; secrets are not.

## Authority and upgrade risk

While `adminAddress` is non-null, the admin can mint, start the two-step admin
handoff, change metadata, drop admin, and upgrade minter code/data. Compromise
of that signer can therefore inflate supply or replace contract behavior.
Use a dedicated testnet signer now and require a reviewed multisig/cold-storage
policy before mainnet. The project deliberately does not call
`DropMinterAdmin` during deployment or minting.

The wallet code is embedded in the Minter build. Rebuild and verify code hashes
before deployment; do not substitute an unreviewed wallet cell.

## Mainnet lock

`TON_NETWORK` defaults to `testnet`. `scripts/run-operation.mjs` rejects
mainnet when `ALLOW_MAINNET_DEPLOY=false` and retains a second unconditional
phase lock even if the flag is changed to `true`. On-chain operation scripts
also require `TON_NETWORK=testnet`. CI never deploys.

## Incident response

If a testnet admin may be compromised, stop operational scripts, record the
Master address and last trusted transaction, and prepare a two-step transfer to
a new admin. Do not change production/mainnet authority based only on a testnet
incident without a separate review.
