import test from 'node:test';
import assert from 'node:assert/strict';
import { assertAllowedNetwork } from '../src/network-guard.mjs';

test('defaults to testnet and accepts explicit testnet', () => {
  assert.equal(assertAllowedNetwork({}), 'testnet');
  assert.equal(assertAllowedNetwork({ TON_NETWORK: 'testnet', ALLOW_MAINNET_DEPLOY: 'false' }), 'testnet');
});

test('mainnet is blocked with both safety-lock states', () => {
  assert.throws(() => assertAllowedNetwork({ TON_NETWORK: 'mainnet', ALLOW_MAINNET_DEPLOY: 'false' }), /mainnet is blocked/);
  assert.throws(() => assertAllowedNetwork({ TON_NETWORK: 'mainnet', ALLOW_MAINNET_DEPLOY: 'true' }), /second mainnet safety lock/);
});

test('unknown networks are blocked', () => {
  assert.throws(() => assertAllowedNetwork({ TON_NETWORK: 'localnet' }), /unsupported network/);
});
