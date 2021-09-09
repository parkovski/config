#!/usr/bin/env node

// Reorganize Virtual Playing Orchestra 3 scripts

const fs = require('fs');
const path = require('path');

// Skip processing these dirs by instrument because there are few files.
const instrSkip = ['keys', 'percussion', 'vocals'];
// Names without a SEC|SOLO end marker.
const instrName = ['harp'];

// TODO: Search and create instrument dirs
// TODO: Verify sample paths before changing
// TODO: Create and search in missing kind directories

function printHelp() {
  console.log(
`Usage: node vpo.js [options] <base-dir>

Options (may be combined like -Cpk):
  --  Stop processing args.

  -h  Print this help message.

  -z  Show changes but don't commit.

  -a  Enable all of the following options:

  -C  Capitalize file names.
  -p  Fix sample paths.
  -P  Remove 'PERF' from names.
  -i  Separate files by instrument.
  -k  Separate files by kind (Standard/Performance).
      Warning: The performance zip folder has some files not marked 'PERF'.
`
  );
}

if (process.argv.length === 2) {
  printHelp();
  process.exit(1);
}

let baseDir = null;
const options = {
  capitalize: false,
  fixPaths: false,
  removePERF: false,
  byInstrument: false,
  byKind: false,
  noCommit: false,
  enableAll: function() {
    this.capitalize = true;
    this.fixPaths = true;
    this.removePERF = true;
    this.byInstrument = true;
    this.byKind = true;
  },
  helpOnly: function() {
    printHelp();
    process.exit(0);
  },
};
const optionMap = {
  a: 'enableAll',
  h: 'helpOnly',
  C: 'capitalize',
  p: 'fixPaths',
  P: 'removePERF',
  i: 'byInstrument',
  k: 'byKind',
  z: 'noCommit',
};
for (let i = 2; i < process.argv.length; i++) {
  const arg = process.argv[i];
  if (arg[0] === '-') {
    if (arg === '--') {
      if (++i != process.argv.length - 1) {
        throw 'Excess options';
      }
      baseDir = process.argv[i];
      break;
    }
    for (let j = 1; j < arg.length; j++) {
      const name = optionMap[arg[j]];
      if (!name) {
        throw 'Unknown option ' + arg[j];
      }
      if (typeof options[name] === 'function') {
        options[name]();
      } else {
        options[name] = true;
      }
    }
  } else if (baseDir) {
    throw 'Excess options';
  } else {
    baseDir = arg;
  }
}

if (!baseDir) {
  printHelp();
  process.exit(1);
}

class File {
  constructor(dir, name, ext) {
    this.dir = dir;
    this.name = name;
    this.ext = ext;

    this.srcDir = path.join.apply(null, dir);
    this.nameParts = name.split('-');
  }

  removePERF() {
    this.nameParts = this.nameParts.filter(p => p !== 'PERF');
  }

  capitalize() {
    for (let i = 0; i < this.nameParts.length; ++i) {
      if (~['SEC', 'SOLO', 'PERF'].indexOf(this.nameParts[i])) {
        break;
      }
      if (!this.nameParts[i].match(/^[a-z]/)) {
        continue;
      }
      this.nameParts[i] =
        `${this.nameParts[i][0].toUpperCase()}${this.nameParts[i].substr(1)}`;
    }
  }

  separateByKind() {
    const d = this.dir[1];
    if (d === 'Standard' || d === 'Performance') {
      return d + ' (not changed)';
    }
    const dest = ~this.name.indexOf('-PERF') ? 'Performance' : 'Standard';
    this.dir = [this.dir[0], dest].concat(this.dir.slice(1));
    return dest;
  }

  separateByInstrument() {
    if (~instrSkip.indexOf(this.dir[this.dir.length - 1].toLowerCase())) {
      return '(skipped)';
    }
    let instrument = this.nameParts[0];
    for (let i = 1; i < this.nameParts.length; ++i) {
      if (~instrName.indexOf(instrument.toLowerCase())) {
        break;
      }
      if (~['SEC', 'SOLO', 'PERF'].indexOf(this.nameParts[i])) {
        break;
      }
      instrument += ' ' + this.nameParts[i];
    }
    if (this.dir[this.dir.length - 1].toLowerCase() !== instrument.toLowerCase()) {
      this.dir = this.dir.concat(instrument);
    }
    return instrument;
  }

  oldName() {
    return path.join(this.srcDir, this.name + this.ext);
  }

  newName() {
    return path.join.apply(null, this.dir.concat(this.nameParts.join('-') + this.ext));
  }

  fixRefs() {
    const name = this.newName();
    const content = fs.readFileSync(name, 'utf-8')
      .replace(/=(\.\.[\\/])*libs/gm, `=${'../'.repeat(this.dir.length - 1)}libs`);
    fs.writeFileSync(name, content, { encoding: 'utf-8' });
  }

  show() {
    const src = path.relative(this.dir[0], this.oldName());
    const dst = path.relative(this.dir[0], this.newName());
    if (src !== dst) {
      console.log(`${src}  =>  ${dst}`);
    }
  }

  commit() {
    const oldName = this.oldName();
    const newName = this.newName();
    if (oldName !== newName) {
      const dir = path.join.apply(null, this.dir);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      fs.renameSync(oldName, newName);
      return true;
    }
    return false;
  }
}

function collect(dir, files) {
  let dirname = dir;
  if (Array.isArray(dir)) {
    dirname = path.join.apply(null, dir);
  } else {
    dir = [dir];
  }
  if (!files) {
    files = [];
  }
  for (const ent of fs.readdirSync(dirname, { withFileTypes: true })) {
    if (ent.isDirectory()) {
      if (ent.name === 'libs') {
        continue;
      }
      collect(dir.concat(ent.name), files);
    } else if (ent.name.endsWith('.sfz')) {
      files.push(new File(dir, ent.name.substr(0, ent.name.length - 4), '.sfz'));
    }
  }
  return files;
}

const files = collect(baseDir);
console.log(`Collected ${files.length} files.`);

const kindCount = {
  Standard: 0,
  'Standard (not changed)': 0,
  Performance: 0,
  'Performance (not changed)': 0,
};
const instCount = {};
let renameCount = 0;

for (const file of files) {
  if (options.removePERF) {
    file.removePERF();
  }
  if (options.capitalize) {
    file.capitalize();
  }
  if (options.byKind) {
    kindCount[file.separateByKind()]++;
  }
  if (options.byInstrument) {
    const inst = file.separateByInstrument();
    instCount[inst] = (instCount[inst] || 0) + 1;
  }

  if (options.noCommit) {
    file.show();
  } else {
    if (file.commit()) {
      ++renameCount;
    }
    if (options.fixPaths) {
      file.fixRefs();
    }
  }
}

if (!options.noCommit) {
  console.log("\nRenamed " + renameCount + " files.");
}

if (options.byKind) {
  console.log("\nBy kind:");
  Object.keys(kindCount).forEach(k => {
    if (kindCount[k]) {
      console.log(`${k}: ${kindCount[k]}`);
    }
  });
}

if (options.byInstrument) {
  const skipped = instCount['(skipped)'];
  delete instCount['(skipped)'];
  console.log("\nBy instrument (skipped " + skipped + "):");
  Object.keys(instCount).forEach(k => {
    console.log(`${k}: ${instCount[k]}`);
  });
}