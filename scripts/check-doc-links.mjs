import fs from 'node:fs';
import path from 'node:path';

const ignoredDirectories = new Set(['.git', '.tmp', 'node_modules']);

function walk(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    if (entry.isDirectory() && ignoredDirectories.has(entry.name)) {
      return [];
    }

    const entryPath = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(entryPath) : [entryPath];
  });
}

const markdownFiles = walk('.').filter((file) => file.endsWith('.md'));
const failures = [];
const localLinkPattern = /\[[^\]]+\]\(([^)]+)\)/g;

for (const file of markdownFiles) {
  const content = fs.readFileSync(file, 'utf8');

  for (const match of content.matchAll(localLinkPattern)) {
    const link = match[1];
    if (/^(https?:|mailto:|#)/.test(link)) {
      continue;
    }

    const filePart = link.split('#', 1)[0];
    if (!filePart) {
      continue;
    }

    const destination = path.resolve(path.dirname(file), decodeURIComponent(filePart));
    if (!fs.existsSync(destination)) {
      failures.push(`${file}: ${link}`);
    }
  }
}

if (failures.length > 0) {
  console.error(`Broken local documentation links:\n${failures.join('\n')}`);
  process.exit(1);
}

console.log(`Documentation links: OK (${markdownFiles.length} Markdown files)`);
