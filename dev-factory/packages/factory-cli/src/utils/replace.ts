import fs from 'node:fs/promises';
import path from 'node:path';
import { listFilesRecursive } from './fs';

const TEXT_EXTS = new Set([
  '.md',
  '.ts',
  '.js',
  '.json',
  '.yml',
  '.yaml',
  '.cjs',
  '.sh',
  '.env',
  '.example',
  '.dockerignore',
  '.prettierrc',
  '.prisma',
  '.sql',
]);

function isTextFile(filePath: string): boolean {
  const base = path.basename(filePath);
  if (base === 'Dockerfile' || base === 'docker-compose.yml') return true;
  return TEXT_EXTS.has(path.extname(filePath));
}

export async function replaceInTextFiles(
  rootDir: string,
  replacements: Record<string, string>,
): Promise<void> {
  const files = await listFilesRecursive(rootDir);
  for (const file of files) {
    if (!isTextFile(file)) continue;
    const buf = await fs.readFile(file);
    const text = buf.toString('utf8');
    let next = text;
    for (const [from, to] of Object.entries(replacements)) {
      next = next.split(from).join(to);
    }
    if (next !== text) {
      await fs.writeFile(file, next);
    }
  }
}
