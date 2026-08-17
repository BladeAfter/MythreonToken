# Pre-deployment security review

Scope: source and local tooling only. No testnet or mainnet deployment has
occurred.

## Contract provenance

- Master and Wallet source: TON Core `acton-contracts/jetton-v2.1`, commit
  `7af1cea3cd0b990ae7b53a67b858c8cbd9da1e16`.
- Standards: TEP-74 transfers/getters, TEP-89 wallet discovery, TEP-64 on-chain
  metadata.
- No MYTH-specific opcodes, fees, taxes, blacklist, pause, price, allocation,
  or transfer restrictions were added.

## Controls reviewed

- Mint checks the current admin sender.
- Admin handoff is two-step (`ChangeMinterAdmin`, then `ClaimMinterAdmin`).
- Wallet transfer and burn check the holder wallet owner and available balance.
- Internal transfer and burn notification validate the canonical wallet/master
  relationship.
- Failed outbound internal transfers and burn notifications restore accounting
  through bounce handlers.
- Wallet derivation uses the Master getter and the same embedded Wallet code.
- Mainnet is blocked in the Node launcher and Tolk operational scripts.
- Deployment initializes supply to zero and does not drop admin.

## Residual risks

1. The admin can mint, change metadata, upgrade Minter code/data, and drop
   authority. Admin compromise is the largest operational risk.
2. `DropMinterAdmin` is irreversible. It must remain a separately reviewed,
   manual future action.
3. Jetton `query_id` is a correlation identifier, not contract-level replay
   protection. Duplicate business requests must be prevented by the signing
   wallet/application workflow; ordinary TON wallet sequence numbers protect
   replay of a signed wallet message. The standard contract intentionally was
   not modified to add a custom nonce registry.
4. Transfer notifications are only emitted when `forward_ton_amount > 0`.
   Future deposit processors must validate the sending Jetton Wallet against
   the official Master, parse the notification, and reconcile the transaction.
5. The image URL is an `.invalid` placeholder and must be replaced with a
   durable HTTPS or IPFS asset before public deployment.
6. Fees are estimates and can change with network configuration; fund the
   signer conservatively and rehearse on testnet.
7. Acton 1.1.0 does not support native Windows. Use Linux, macOS, supported
   Docker, or WSL; CI uses Ubuntu.

## Release gate before testnet

- `npm run check` exits 0 on a supported Acton host.
- Review compiled Minter and Wallet hashes.
- Replace and independently verify the image URL.
- Confirm `OWNER_ADDRESS`, signer wallet network, and zero initial supply.
- Obtain explicit human authorization for testnet deployment.
