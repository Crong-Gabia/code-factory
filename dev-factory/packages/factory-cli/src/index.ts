#!/usr/bin/env node

import { runPrompts } from './prompts';
import { generateProject } from './generator';
import { resolveTemplate } from './template';

async function main() {
  const answers = await runPrompts();
  const template = resolveTemplate(answers);
  await generateProject({
    projectName: answers.projectName,
    templateDir: template.templateDir,
  });
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
