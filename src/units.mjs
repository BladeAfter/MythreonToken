export const MYTH_DECIMALS = 9;
export const MYTH_SCALE = 1_000_000_000n;
export const PLANNED_SUPPLY = 100_000_000n * MYTH_SCALE;

const DECIMAL_AMOUNT = /^(0|[1-9]\d*)(?:\.(\d{1,9}))?$/;
const INTEGER_AMOUNT = /^(0|[1-9]\d*)$/;

export function toMythUnits(value) {
  if (typeof value !== 'string') {
    throw new TypeError('MYTH amount must be a decimal string');
  }

  const match = DECIMAL_AMOUNT.exec(value);
  if (!match) {
    throw new RangeError('Invalid MYTH amount; use a non-negative decimal string with at most 9 decimals');
  }

  const whole = BigInt(match[1]);
  const fraction = (match[2] ?? '').padEnd(MYTH_DECIMALS, '0');
  return whole * MYTH_SCALE + BigInt(fraction || '0');
}

export function fromMythUnits(value) {
  const raw = typeof value === 'bigint' ? value : typeof value === 'string' && INTEGER_AMOUNT.test(value) ? BigInt(value) : null;
  if (raw === null || raw < 0n) {
    throw new RangeError('Base units must be a non-negative bigint or integer string');
  }

  const whole = raw / MYTH_SCALE;
  const remainder = raw % MYTH_SCALE;
  if (remainder === 0n) return whole.toString();
  const fraction = remainder.toString().padStart(MYTH_DECIMALS, '0').replace(/0+$/, '');
  return `${whole}.${fraction}`;
}
