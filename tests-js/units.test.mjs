import test from 'node:test';
import assert from 'node:assert/strict';
import { fromMythUnits, MYTH_SCALE, PLANNED_SUPPLY, toMythUnits } from '../src/units.mjs';

test('converts required 9-decimal MYTH values exactly', () => {
  assert.equal(toMythUnits('1'), 1_000_000_000n);
  assert.equal(toMythUnits('0.1'), 100_000_000n);
  assert.equal(toMythUnits('0.001'), 1_000_000n);
  assert.equal(fromMythUnits(1_000_000_000n), '1');
  assert.equal(fromMythUnits('100000000'), '0.1');
  assert.equal(fromMythUnits(1_000_000n), '0.001');
});

test('planned supply is exact and uses bigint', () => {
  assert.equal(MYTH_SCALE, 1_000_000_000n);
  assert.equal(PLANNED_SUPPLY, 100_000_000_000_000_000n);
  assert.equal(fromMythUnits(PLANNED_SUPPLY), '100000000');
});

test('rejects float-like and imprecise inputs', () => {
  assert.throws(() => toMythUnits(0.1), TypeError);
  assert.throws(() => toMythUnits('0.0000000001'), RangeError);
  assert.throws(() => toMythUnits('-1'), RangeError);
  assert.throws(() => toMythUnits('1e9'), RangeError);
  assert.throws(() => fromMythUnits(1), RangeError);
});

test('round-trips representative values without Number or parseFloat', () => {
  for (const amount of ['0', '0.000000001', '10', '1000', '99999999.999999999']) {
    assert.equal(fromMythUnits(toMythUnits(amount)), amount);
  }
});
