#!/usr/bin/env node

const { execFileSync } = require('child_process');
const path = require('path');

const install = path.join(__dirname, '..', 'install.sh');

execFileSync('bash', [install, ...process.argv.slice(2)], { stdio: 'inherit' });
