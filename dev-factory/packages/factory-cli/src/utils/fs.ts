import fs from 'node:fs/promises';
import path from 'node:path';

export async function ensureDir(dirPath: string): Promise<void> {
  await fs.mkdir(dirPath, { recursive: true });
}

export async function copyDir(srcDir: string, destDir: string): Promise<void> {
  await ensureDir(destDir);
  const entries = await fs.readdir(srcDir, { withFileTypes: true });

  for (const entry of entries) {
    const src = path.join(srcDir, entry.name);
    const dest = path.join(destDir, entry.name);

    if (entry.isDirectory()) {
      await copyDir(src, dest);
      continue;
    }
    if (entry.isSymbolicLink()) {
      const link = await fs.readlink(src);
      await fs.symlink(link, dest);
      continue;
    }
    if (entry.isFile()) {
      await fs.copyFile(src, dest);
      const st = await fs.stat(src);
      await fs.chmod(dest, st.mode);
    }
  }
}

export async function listFilesRecursive(dirPath: string): Promise<string[]> {
  const out: string[] = [];
  const entries = await fs.readdir(dirPath, { withFileTypes: true });
  for (const entry of entries) {
    const full = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      out.push(...(await listFilesRecursive(full)));
    } else if (entry.isFile()) {
      out.push(full);
    }
  }
  return out;
}
