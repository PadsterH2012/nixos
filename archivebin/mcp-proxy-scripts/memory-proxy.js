#!/usr/bin/env node

/**
 * memory MCP Proxy
 * Connects to centralized memory server
 */

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const proxyScript = join(__dirname, 'mcp-http-proxy.js');
const serverName = 'memory';
const baseUrl = 'http://10.202.28.111:9090';

// Spawn the generic proxy with memory-specific parameters
const proxy = spawn('node', [proxyScript, serverName, baseUrl], {
  stdio: 'inherit'
});

proxy.on('error', (error) => {
  console.error(`Failed to start memory proxy: ${error.message}`);
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