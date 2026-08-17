import { spawnSync } from 'node:child_process';

const mode = process.argv[2] ?? 'all';
const commands = mode === 'test'
  ? [['node', ['--test', 'tests-js/*.test.mjs']], ['acton', ['test', 'tests']]]
  : mode === 'lint'
    ? [['node', ['scripts/project-lint.mjs']], ['acton', ['check']], ['acton', ['fmt', '--check']]]
    : [['acton', ['build']], ['node', ['--test', 'tests-js/*.test.mjs']], ['acton', ['test', 'tests']], ['node', ['scripts/project-lint.mjs']], ['acton', ['check']], ['acton', ['fmt', '--check']]];

for (const [command, args] of commands) {
  const result = spawnSync(command, args, { stdio: 'inherit', shell: process.platform === 'win32' });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}
