#!/usr/bin/env node

function parsePaletton(text) {
  const lines = text.split(/\r?\n/);
  let name;
  let json = {};
  for (const line of lines) {
    let match = line.match(/^\*\*\* ([A-Z][a-z]+) color(?: \((.)\))?:/);
    if (match) {
      name = match[1].toLowerCase();
      if (match[2] === '2') {
        name = 'tertiary';
      } else if (match[3] === '3') {
        name = 'quaternary';
      }
      json[name] = [];
      continue;
    }

    match = line.match(/^[ ]+shade . = (#[A-Z0-9]+)/);
    if (match) {
      json[name].push(match[1]);
    }
  }
  return json;
}
module.exports = parsePaletton;

if (require.main === module) {
  const fs = require('fs');

  const filename = process.argv[2];
  let text = '';
  if (!filename || filename === '-') {
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', d => text += d);
    process.stdin.on('end', () => {
      process.stdout.write(JSON.stringify(parsePaletton(text)) + '\n');
    });
    process.stdin.resume();
  } else {
    text = fs.readFileSync(filename, 'utf8');
    process.stdout.write(JSON.stringify(parsePaletton(text)) + '\n');
  }
}