const fs = require('fs');
const path = require('path');
const spawnSync = require('child_process').spawnSync;

const listpath = path.resolve(__dirname, '../etc/vimcolors.txt');
const colorspath = path.resolve(process.env.HOME, '.vim/colors');
let colors
  = fs.readFileSync(listpath, 'utf-8')
    .split('\n')
    .filter(x => x);

colors.forEach(c => {
  const shortname = c.substr(c.lastIndexOf('/') + 1);
  if (fs.existsSync(path.resolve(colorspath, shortname))) {
    console.log('Skipping ' + shortname + ' because it already exists.');
    return;
  }
  process.stdout.write('Downloading ' + shortname + '... ');
  const res = spawnSync('curl', ['-sLO', c], { cwd: colorspath });
  if (res.error) {
    process.stdout.write('\n');
    throw res.error;
  }
  if (res.status) {
    process.stdout.write('\n');
    process.exit(res.status);
  }
  process.stdout.write('done.\n');
});

