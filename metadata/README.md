# MYTH token artwork

`myth-token-icon.png` is the project-local, wallet-oriented version derived
from the artwork supplied by the Mythreon owner.

Properties:

- PNG
- Square, 1254 × 1254 pixels
- Gold Mythreon “M” and dragon over a purple/blue cosmic background
- Intended use: MYTH Jetton icon in wallets and explorers

Before testnet deployment, publish this exact reviewed file at a durable HTTPS
or IPFS URL, verify the downloaded SHA-256, and replace `JETTON_IMAGE` plus the
placeholder `image` values in `config/token.json` and `metadata/jetton.json`.
Local paths must not be written into TEP-64 on-chain metadata because external
wallets and explorers cannot resolve repository files.
