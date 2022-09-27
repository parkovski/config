#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const spawnSync = require('child_process').spawnSync;
const os = require('os');
const WIN32 = os.platform() === 'win32';
const HOME = os.homedir();
const CURL = WIN32 ? 'curl.exe' : 'curl';

const listpath = path.resolve(HOME, '.share/etc/vimcolors.txt');
const colorspath = path.resolve(HOME, WIN32 ? 'vimfiles' : '.vim', 'colors');
if (!fs.existsSync(colorspath)) {
  fs.mkdirSync(colorspath);
}
let colors
  = fs.readFileSync(listpath, 'utf-8')
    .split(/\r?\n/)
    .filter(x => x);

process.stdout.write(`${colors.length} colors to download.\n`);
colors.forEach(c => {
  const shortname = c.substr(c.lastIndexOf('/') + 1);
  if (fs.existsSync(path.resolve(colorspath, shortname))) {
    process.stdout.write('Skipping ' + shortname + ' because it already exists.\n');
    return;
  }
  process.stdout.write('Downloading ' + shortname + '... \n');
  const res = spawnSync(CURL, ['-sLO', c], { cwd: colorspath });
  if (res.status) {
    process.stdout.write('Curl returned ' + res.status + '.\n');
  }
  if (res.error) {
    process.stdout.write(res.error.toString());
    process.stdout.write('\n');
  }
});
