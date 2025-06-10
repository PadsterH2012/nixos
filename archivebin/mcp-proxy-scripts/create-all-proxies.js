#!/usr/bin/env node

/**
 * Script to generate all MCP proxy scripts
 */

import { writeFileSync } from 'fs';
import { join } from 'path';

const servers = [
  'brave-search',
  'memory', 
  'mongodb',
  'Context7',
  'jenkins-mcp',
  'proxmox-mcp'
];

const proxyTemplate = (serverName) => `#!/usr/bin/env node

/**
 * ${serverName} MCP Proxy
 * Connects to centralized ${serverName} server
 */

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const proxyScript = join(__dirname, 'mcp-http-proxy.js');
const serverName = '${serverName}';
const baseUrl = 'http://10.202.28.111:9090';

// Spawn the generic proxy with ${serverName}-specific parameters
const proxy = spawn('node', [proxyScript, serverName, baseUrl], {
  stdio: 'inherit'
});

proxy.on('error', (error) => {
  console.error(\`Failed to start ${serverName} proxy: \${error.message}\`);
  process.exit(1);
});

proxy.on('exit', (code) => {
  process.exit(code);
});

// Handle cleanup
process.on('SIGINT', () => {
  proxy.kill('SIGINT');
});

process.on('SIGTERM', () => {
  proxy.kill('SIGTERM');
});`;

// Generate proxy scripts for remaining servers
servers.forEach(serverName => {
  const filename = `${serverName.toLowerCase().replace('-', '_')}-proxy.js`;
  const content = proxyTemplate(serverName);
  
  try {
    writeFileSync(filename, content);
    console.log(`Created ${filename}`);
  } catch (error) {
    console.error(`Failed to create ${filename}: ${error.message}`);
  }
});

console.log('All proxy scripts created successfully!');
