#!/usr/bin/env node

/**
 * brave-search MCP Proxy
 * Connects to centralized brave-search server
 */

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const proxyScript = join(__dirname, 'mcp-http-proxy.js');
const serverName = 'brave-search';
const baseUrl = 'http://10.202.28.111:9090';

// Spawn the generic proxy with brave-search-specific parameters
const proxy = spawn('node', [proxyScript, serverName, baseUrl], {
  stdio: 'inherit'
});

proxy.on('error', (error) => {
  console.error(`Failed to start brave-search proxy: ${error.message}`);
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
});