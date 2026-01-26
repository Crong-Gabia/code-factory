/* eslint-env node */

const { spawnSync } = require("node:child_process");

function run(cmd, args) {
  const r = spawnSync(cmd, args, { stdio: "inherit", shell: false });
  if (r.status !== 0) process.exit(r.status ?? 1);
}

const hasDb = Boolean(process.env.DATABASE_URL);

if (hasDb) {
  run("bash", ["./scripts/wait-mysql.sh"]);
  run("npm", ["run", "prisma:migrate"]);
}

run("node", ["./node_modules/jest/bin/jest.js", "--runInBand"]);
