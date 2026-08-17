# MYTH token artwork

`myth-token-icon.png` is the original artwork supplied and approved by the
Mythreon owner. `myth-token-icon-wallet.png` is the non-destructive adaptation
selected for token metadata: the same dragon, golden Mythreon M, purple gems,
and blue/purple cosmic identity, with filled square corners and safer framing
for circular wallet crops.

Properties:

- Square PNG artwork
- Gold Mythreon “M” and dragon over a purple/blue cosmic background
- Intended use: MYTH Jetton icon in wallets and explorers

SHA-256 checksums:

- Original: `71A5F5DDB60BC9D7156FFBB7BC09DCE56205DCE69F03EFD5887FA1C99C19ACD0`
- Wallet-safe: `9F2B4D989C870C1DCFABC15FB02F7B3441646222F18533034459AAE2287648F1`

Before testnet deployment, publish the wallet-safe file at a durable HTTPS
or IPFS URL, verify the downloaded SHA-256, and replace `JETTON_IMAGE` plus the
placeholder `image` values in `config/token.json` and `metadata/jetton.json`.
Local paths must not be written into TEP-64 on-chain metadata because external
wallets and explorers cannot resolve repository files.
