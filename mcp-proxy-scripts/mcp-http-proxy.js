#!/usr/bin/env node

/**
 * MCP HTTP Proxy - Bridges HTTP/SSE MCP servers to command-line interface
 * Usage: node mcp-http-proxy.js <server-name>
 */

import fetch from 'node-fetch';
import EventSource from 'eventsource';

class MCPHttpProxy {
  constructor(serverName, baseUrl) {
    this.serverName = serverName;
    this.baseUrl = baseUrl;
    this.sseUrl = `${baseUrl}/${serverName}/sse`;
    this.messageUrl = `${baseUrl}/${serverName}/message`;
    this.eventSource = null;
    this.messageId = 1;
    this.pendingRequests = new Map();
  }

  async start() {
    try {
      // Connect to SSE endpoint
      this.eventSource = new EventSource(this.sseUrl);
      
      this.eventSource.onopen = () => {
        this.log(`Connected to ${this.serverName} SSE endpoint`);
      };

      this.eventSource.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          this.handleServerMessage(data);
        } catch (error) {
          this.log(`Error parsing SSE message: ${error.message}`);
        }
      };

      this.eventSource.onerror = (error) => {
        this.log(`SSE connection error: ${error.message || 'Unknown error'}`);
      };

      // Set up stdin/stdout communication
      this.setupStdioInterface();
      
    } catch (error) {
      this.log(`Failed to start proxy: ${error.message}`);
      process.exit(1);
    }
  }

  setupStdioInterface() {
    process.stdin.setEncoding('utf8');
    
    let buffer = '';
    process.stdin.on('data', (chunk) => {
      buffer += chunk;
      
      // Process complete JSON messages (separated by newlines)
      const lines = buffer.split('\n');
      buffer = lines.pop(); // Keep incomplete line in buffer
      
      for (const line of lines) {
        if (line.trim()) {
          try {
            const message = JSON.parse(line);
            this.handleClientMessage(message);
          } catch (error) {
            this.log(`Error parsing client message: ${error.message}`);
          }
        }
      }
    });

    process.stdin.on('end', () => {
      this.cleanup();
    });

    process.on('SIGINT', () => {
      this.cleanup();
    });

    process.on('SIGTERM', () => {
      this.cleanup();
    });
  }

  async handleClientMessage(message) {
    try {
      // Add message ID for tracking
      const messageWithId = {
        ...message,
        id: this.messageId++
      };

      // Store pending request
      this.pendingRequests.set(messageWithId.id, {
        timestamp: Date.now(),
        originalMessage: message
      });

      // Forward to HTTP MCP server
      const response = await fetch(this.messageUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(messageWithId)
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      // For non-SSE responses, handle immediately
      if (!response.headers.get('content-type')?.includes('text/event-stream')) {
        const responseData = await response.json();
        this.sendToClient(responseData);
        this.pendingRequests.delete(messageWithId.id);
      }

    } catch (error) {
      this.log(`Error handling client message: ${error.message}`);
      
      // Send error response to client
      this.sendToClient({
        jsonrpc: "2.0",
        id: message.id,
        error: {
          code: -32603,
          message: `Proxy error: ${error.message}`
        }
      });
    }
  }

  handleServerMessage(data) {
    // Forward server response to client
    this.sendToClient(data);
    
    // Clean up pending request if this is a response
    if (data.id && this.pendingRequests.has(data.id)) {
      this.pendingRequests.delete(data.id);
    }
  }

  sendToClient(data) {
    const message = JSON.stringify(data) + '\n';
    process.stdout.write(message);
  }

  log(message) {
    // Log to stderr so it doesn't interfere with stdout communication
    process.stderr.write(`[MCP-Proxy-${this.serverName}] ${message}\n`);
  }

  cleanup() {
    this.log('Cleaning up...');
    
    if (this.eventSource) {
      this.eventSource.close();
    }
    
    // Clear pending requests
    this.pendingRequests.clear();
    
    process.exit(0);
  }
}

// Main execution
const serverName = process.argv[2];
const baseUrl = process.argv[3] || 'http://10.202.28.111:9090';

if (!serverName) {
  console.error('Usage: node mcp-http-proxy.js <server-name> [base-url]');
  console.error('Example: node mcp-http-proxy.js obsidian-mcp-tools');
  process.exit(1);
}

const proxy = new MCPHttpProxy(serverName, baseUrl);
proxy.start().catch((error) => {
  console.error(`Failed to start proxy: ${error.message}`);
  process.exit(1);
});
