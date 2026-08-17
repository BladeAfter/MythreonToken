import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const roots = ['src', 'scripts', 'config', 'metadata'];
const files = [];
function walk(path) {
  for (const name of readdirSync(path)) {
    const full = join(path, name);
    if (statSync(full).isDirectory()) walk(full);
    else files.push(full);
  }
}
for (const root of roots) walk(root);

const failures = [];
for (const file of files) {
  const text = readFileSync(file, 'utf8');
  if (/\b(?:parseFloat|parseInt|Number)\s*\(/.test(text) && file.includes(`${join('', 'src')}`)) {
    failures.push(`${relative('.', file)} uses an unsafe numeric conversion`);
  }
  if (/\b(?:mnemonic|seed phrase|private key)\s*=\s*[^\s]/i.test(text)) {
    failures.push(`${relative('.', file)} appears to embed key material`);
  }
}

const metadata = JSON.parse(readFileSync('metadata/jetton.json', 'utf8'));
for (const [key, expected] of Object.entries({ name: 'Mythreon Token', symbol: 'MYTH', decimals: '9', description: 'The official ecosystem token of Mythreon.' })) {
  if (metadata[key] !== expected) failures.push(`metadata.${key} is invalid`);
}
if (!metadata.image.startsWith('https://') || /localhost|lovable|\.invalid(?:\/|$)/i.test(metadata.image)) failures.push('metadata.image must be a durable non-local HTTPS URL');

const iconPath = join('metadata', metadata.image_local_asset);
const expectedIconSha256 = '9F2B4D989C870C1DCFABC15FB02F7B3441646222F18533034459AAE2287648F1';
if (!existsSync(iconPath)) {
  failures.push(`metadata.image_local_asset does not exist: ${iconPath}`);
} else {
  const actualIconSha256 = createHash('sha256').update(readFileSync(iconPath)).digest('hex').toUpperCase();
  if (actualIconSha256 !== expectedIconSha256) failures.push('official wallet icon SHA-256 is invalid');
}

if (failures.length) {
  console.error(failures.join('\n'));
  process.exit(1);
}
console.log(`Project checks passed (${files.length} files inspected).`);
