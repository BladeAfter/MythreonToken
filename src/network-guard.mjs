export function assertAllowedNetwork(env = process.env) {
  const network = (env.TON_NETWORK ?? 'testnet').trim().toLowerCase();
  const allowMainnet = (env.ALLOW_MAINNET_DEPLOY ?? 'false').trim().toLowerCase() === 'true';

  if (network === 'mainnet' && !allowMainnet) {
    throw new Error('ABORT: mainnet is blocked (ALLOW_MAINNET_DEPLOY is not true).');
  }
  if (network === 'mainnet' && allowMainnet) {
    throw new Error('ABORT: this project phase is testnet-only; the second mainnet safety lock is active.');
  }
  if (network !== 'testnet') {
    throw new Error(`ABORT: unsupported network "${network}"; expected testnet.`);
  }
  return network;
}
