import { input, select } from '@inquirer/prompts';

export type FrameworkChoice = 'express' | 'nest';
export type DbChoice = 'mysql';

export type Answers = {
  projectName: string;
  framework: FrameworkChoice;
  db: DbChoice;
};

function normalizeProjectName(name: string): string {
  return name.trim();
}

function validateProjectName(name: string): true | string {
  const n = normalizeProjectName(name);
  if (!n) return 'Project name is required.';
  if (!/^[a-zA-Z0-9][a-zA-Z0-9-_]*$/.test(n)) {
    return 'Use letters, numbers, dash, underscore. Must not start with a symbol.';
  }
  return true;
}

export async function runPrompts(): Promise<Answers> {
  const projectName = normalizeProjectName(
    await input({
      message: 'Project name',
      validate: validateProjectName,
    }),
  );

  const framework = await select<FrameworkChoice>({
    message: 'Framework',
    choices: [
      { name: 'Express', value: 'express' },
      { name: 'Nest', value: 'nest' },
    ],
  });

  const db = await select<DbChoice>({
    message: 'Database',
    choices: [
      { name: 'MySQL', value: 'mysql' },
      { name: 'PostgreSQL (coming soon)', value: 'mysql', disabled: true },
      { name: 'SQLite (coming soon)', value: 'mysql', disabled: true },
    ],
  });

  return { projectName, framework, db };
}
