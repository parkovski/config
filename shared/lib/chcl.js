#!/usr/bin/env node

const os = require('os');
const HOME = os.userInfo().homedir;

const vars = ['CC', 'CFLAGS', 'CXX', 'CXXFLAGS', 'LDFLAGS', 'CMAKE_PREFIX_PATH']
  .reduce((o, v) => { o[v] = null; return o; }, Object.create(null));

function showHelp() {
  console.log(`echo 'usage: chcl [-h|-l|-z] <cc> <cxx> [var=value]...'`);
  console.log(`echo '-h prints this message'`);
  console.log(`echo '-l or no arguments will print the current compiler env'`);
  console.log(`echo '-z shows the commands instead of running them'`);
  console.log(`echo "if <cc> contains 'clang' or 'gcc', <cxx> is inferred,"`);
  console.log(`echo '  otherwise it is guessed'`);
  console.log(`echo "if <cc> contains 'clang' and <cxx> is 'libc++',"`);
  console.log(`echo '  <cxx> is inferred and additional flags are set for libc++'`);
  console.log(`echo 'other env vars in [var=value]... are set,'`);
  console.log(`echo '  with var converted to upper case'`);
}

function showEnvVars() {
  Object.keys(vars).forEach(v => console.log(`echo "${v} = $${v}"`));
}

let simulate = false;
for (let i = 2; i < process.argv.length; ++i) {
  let arg = process.argv[i];
  let eq = arg.indexOf('=');
  if (arg == '-h') {
    showHelp();
    process.exit();
  } else if (arg == '-l') {
    showEnvVars();
    process.exit();
  } else if (arg == '-z') {
    simulate = true;
  } else if (~eq) {
    let name = arg.substring(0, eq).toUpperCase();
    let value = arg.substring(eq + 1);
    vars[name] = value;
  } else if (!vars.CC) {
    vars.CC = arg;
  } else if (!vars.CXX) {
    vars.CXX = arg;
  } else {
    console.log(`echo "don't know what to do with arg '$${i - 1}'"`);
    process.exit(1);
  }
}

if (!vars.CC) {
  showEnvVars();
  process.exit();
}

const local_include = `-I${HOME}/.local/include`;
const local_lib = `-L${HOME}/.local/lib`;

vars.CFLAGS = vars.CFLAGS || local_include;
vars.CXXFLAGS = vars.CXXFLAGS || local_include;
vars.LDFLAGS = vars.LDFLAGS || local_lib;
vars.CMAKE_PREFIX_PATH = `-L${HOME}/.local`;

let ioGcc = vars.CC.indexOf('gcc');
let ioClang = vars.CC.indexOf('clang');

if (~ioClang && vars.CXX == 'libc++') {
  vars.CXX = undefined;
  vars.CXXFLAGS = `-stdlib=libc++ -I${HOME}/.local/lib.libc++/include `
    + vars.CXXFLAGS;
  vars.LDFLAGS = `-L${HOME}/.local/lib.libc++/lib ` + vars.LDFLAGS;
  vars.CMAKE_PREFIX_PATH = `-L${HOME}/.local/lib.libc++;-L${HOME}/.local`;
}

if (!vars.CXX) {
  if (~ioGcc) {
    vars.CXX = vars.CC.substring(0, ioGcc + 1) + '++' +
      vars.CC.substring(ioGcc + 3);
  } else if (~ioClang) {
    vars.CXX = vars.CC.substring(0, ioClang + 5) + '++' +
      vars.CC.substring(ioClang + 5);
  } else {
    vars.CXX = vars.CC + '++';
  }
}

Object.keys(vars).forEach(env => {
  const penv = process.env[env];
  const value = vars[env];

  if (penv == value) {
    return;
  }

  if (env == 'PATH') {
    if (!value) return;

    let sep = require('path').delimiter;
    if (simulate) {
      console.log(`echo "export PATH=\\"${value}${sep}$PATH\\""`);
    } else {
      console.log(`export PATH="${value}${sep}$PATH"`);
    }
    return;
  }

  if (simulate) {
    console.log(`echo "export ${env}='${value}'"`);
  } else {
    console.log(`export ${env}='${value}'`);
  }
});

if (!simulate) {
  showEnvVars();
}
