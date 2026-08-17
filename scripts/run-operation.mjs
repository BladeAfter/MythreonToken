import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { loadEnvFile } from 'node:process';
import { createInterface } from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import { assertAllowedNetwork } from '../src/network-guard.mjs';
import { toMythUnits } from '../src/units.mjs';

if (existsSync('.env')) loadEnvFile('.env');
const operation = process.argv[2];
const network = assertAllowedNetwork();
const owner = process.env.OWNER_ADDRESS?.trim() ?? '';
const minter = process.env.JETTON_MINTER_ADDRESS?.trim() ?? '';

const operations = {
  deploy: { script: 'scripts/deploy.tolk', signed: true, tons: '~0.05 TON', amount: '0 MYTH' },
  mint: { script: 'scripts/mint.tolk', signed: true, tons: '~0.08 TON', amount: process.env.MINT_AMOUNT_MYTH ?? '1000' },
  transfer: { script: 'scripts/transfer.tolk', signed: true, tons: '~0.08 TON', amount: process.env.TRANSFER_AMOUNT_MYTH ?? '10' },
  burn: { script: 'scripts/burn.tolk', signed: true, tons: '~0.08 TON', amount: process.env.BURN_AMOUNT_MYTH ?? '10' },
  verify: { script: 'scripts/verify-token.tolk', signed: false, tons: '0 TON (read-only)', amount: 'n/a' },
  wallet: { script: 'scripts/wallet-address.tolk', signed: false, tons: '0 TON (read-only)', amount: 'n/a' },
};

const selected = operations[operation];
if (!selected) throw new Error(`Unknown operation: ${operation ?? '<missing>'}`);
if (operation === 'deploy' && !owner) throw new Error('OWNER_ADDRESS is required for deployment.');
if (operation !== 'deploy' && !minter) throw new Error('JETTON_MINTER_ADDRESS is required.');

const childEnv = { ...process.env, TON_NETWORK: network, JETTON_ADMIN_ADDRESS: owner };
if (operation === 'deploy') childEnv.JETTON_INITIAL_SUPPLY = '0';
if (operation === 'mint') {
  childEnv.JETTON_MINT_AMOUNT = toMythUnits(selected.amount).toString();
  childEnv.JETTON_MINT_RECIPIENT ||= owner;
}
if (operation === 'transfer') childEnv.JETTON_TRANSFER_AMOUNT = toMythUnits(selected.amount).toString();
if (operation === 'burn') childEnv.JETTON_BURN_AMOUNT = toMythUnits(selected.amount).toString();

console.log('\nMYTH operation preflight');
console.log(`Operation: ${operation}`);
console.log(`Network: ${network.toUpperCase()}`);
console.log('Token Name: Mythreon Token');
console.log('Symbol: MYTH');
console.log('Decimals: 9');
console.log(`Admin Wallet: ${owner || '<read from chain / not required>'}`);
console.log(`Jetton Master: ${minter || '<will be derived during deploy>'}`);
console.log(`${operation === 'deploy' ? 'Initial Mint' : 'Amount'}: ${selected.amount}`);
console.log(`Estimated TON required: ${selected.tons}`);
console.log(`Signer: ${selected.signed ? 'external wallet via TON Connect' : 'none'}`);

if (selected.signed) {
  const rl = createInterface({ input: stdin, output: stdout });
  const answer = await rl.question('Type TESTNET to authorize opening the signer: ');
  rl.close();
  if (answer !== 'TESTNET') throw new Error('Operation cancelled: explicit TESTNET confirmation not received.');
}

const args = ['script', selected.script, '--net', 'testnet'];
if (selected.signed) args.push('--tonconnect');
const result = spawnSync('acton', args, { cwd: process.cwd(), env: childEnv, stdio: 'inherit', shell: process.platform === 'win32' });
if (result.error) throw result.error;
process.exit(result.status ?? 1);
