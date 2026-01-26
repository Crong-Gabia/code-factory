import path from 'node:path';
import type { Answers } from './prompts';

export type ResolvedTemplate = {
  id: 'api-express-mysql' | 'api-nest-mysql';
  templateDir: string;
};

export function resolveTemplate(answers: Answers): ResolvedTemplate {
  const templatesRoot = path.resolve(__dirname, '../../templates');

  if (answers.framework === 'express' && answers.db === 'mysql') {
    return {
      id: 'api-express-mysql',
      templateDir: path.join(templatesRoot, 'api-express-mysql'),
    };
  }

  return {
    id: 'api-nest-mysql',
    templateDir: path.join(templatesRoot, 'api-nest-mysql'),
  };
}
