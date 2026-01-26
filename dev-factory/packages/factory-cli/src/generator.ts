import path from 'node:path';
import fs from 'node:fs/promises';
import { copyDir } from './utils/fs';
import { replaceInTextFiles } from './utils/replace';

export type GenerateProjectParams = {
  projectName: string;
  templateDir: string;
};

export async function generateProject(params: GenerateProjectParams): Promise<void> {
  const outputRoot = path.resolve(__dirname, '../../../output');
  const outDir = path.join(outputRoot, params.projectName);

  await copyDir(params.templateDir, outDir);
  await replaceInTextFiles(outDir, {
    __PROJECT_NAME__: params.projectName,
  });

  // Ensure shell scripts are executable even if the template was checked out without file modes.
  await chmodShellScripts(outDir);

  // eslint-disable-next-line no-console
  console.log(`Generated: ${outDir}`);
  // eslint-disable-next-line no-console
  console.log(`Next:\n  cd ${outDir}\n  docker compose up --build -d`);
}

async function chmodShellScripts(projectDir: string): Promise<void> {
  const scriptsDir = path.join(projectDir, 'scripts');
  try {
    await chmodShellScriptsRecursive(scriptsDir);
  } catch {
    // ignore
  }
}

async function chmodShellScriptsRecursive(dir: string): Promise<void> {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  await Promise.all(
    entries.map(async (e) => {
      const fullPath = path.join(dir, e.name);
      if (e.isDirectory()) {
        await chmodShellScriptsRecursive(fullPath);
        return;
      }
      if (e.isFile() && e.name.endsWith('.sh')) {
        await fs.chmod(fullPath, 0o755);
      }
    }),
  );
}
