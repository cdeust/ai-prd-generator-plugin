#!/usr/bin/env node
/**
 * Tests for AI Architect PRD Generator MCP Server
 *
 * Covers: health check, config, strategies, and MCP protocol.
 *
 * Run: node --test mcp-server/index.test.js
 * Zero dependencies — uses Node.js built-in test runner.
 */

const { describe, it, before, after } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { execFileSync, spawn } = require("node:child_process");

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const SERVER_PATH = path.join(__dirname, "index.js");

/** Run a tool via --cli mode and return parsed JSON result. */
function cli(toolName, args = {}) {
  const result = execFileSync(
    process.execPath,
    [SERVER_PATH, "--cli", toolName, JSON.stringify(args)],
    {
      encoding: "utf8",
      timeout: 10_000,
      env: {
        ...process.env,
        AIPRD_ENGINE_HOME: TEST_HOME,
        CLAUDE_PLUGIN_ROOT: path.join(__dirname, ".."),
      },
    }
  );
  return JSON.parse(result);
}

/** Create a temporary directory for test isolation. */
let TEST_HOME;

function setupTestHome() {
  TEST_HOME = fs.mkdtempSync(path.join(os.tmpdir(), "aiprd-test-"));
}

function cleanupTestHome() {
  try {
    fs.rmSync(TEST_HOME, { recursive: true, force: true });
  } catch (_) {}
}

/**
 * Send a JSON-RPC request to the MCP server via stdio and return the response.
 */
function mcpRequest(msg) {
  return new Promise((resolve, reject) => {
    const proc = spawn(process.execPath, [SERVER_PATH], {
      env: {
        ...process.env,
        AIPRD_ENGINE_HOME: TEST_HOME,
        CLAUDE_PLUGIN_ROOT: path.join(__dirname, ".."),
      },
      stdio: ["pipe", "pipe", "pipe"],
    });

    const body = JSON.stringify(msg);
    const frame = `Content-Length: ${Buffer.byteLength(body)}\r\n\r\n${body}`;

    let stdout = "";
    proc.stdout.on("data", (chunk) => { stdout += chunk.toString(); });

    const timeout = setTimeout(() => {
      proc.kill("SIGTERM");
    }, 3000);

    proc.on("close", () => {
      clearTimeout(timeout);
      const match = stdout.match(/Content-Length:\s*(\d+)\r?\n\r?\n([\s\S]*)/);
      if (!match) {
        resolve(null);
        return;
      }
      try {
        resolve(JSON.parse(match[2].slice(0, parseInt(match[1], 10))));
      } catch (e) {
        reject(new Error(`Failed to parse MCP response: ${e.message}\n${stdout}`));
      }
    });

    proc.stdin.write(frame);
    setTimeout(() => proc.stdin.end(), 500);
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe("Check Health (CLI mode)", () => {
  before(setupTestHome);
  after(cleanupTestHome);

  it("should return healthy status", () => {
    const result = cli("check_health");
    assert.equal(result.status, "ok");
    assert.ok(result.version);
    assert.ok(result.environment);
    assert.ok(result.timestamp);
  });
});

describe("Get Config (CLI mode)", () => {
  before(setupTestHome);
  after(cleanupTestHome);

  it("should return config with expected fields", () => {
    const result = cli("get_config");
    assert.ok(result.version);
    assert.ok(result.name);
    assert.ok(result.environment);
    assert.ok(result.engine_home);
    assert.ok(result.plugin_root);
  });
});

describe("List Available Strategies (CLI mode)", () => {
  before(setupTestHome);
  after(cleanupTestHome);

  it("should return all strategies", () => {
    const result = cli("list_available_strategies");
    assert.ok(Array.isArray(result.strategies));
    assert.ok(result.total_available > 0);
    assert.ok(result.strategies.includes("zero_shot"));
    assert.ok(result.strategies.includes("chain_of_thought"));
    assert.ok(result.strategies.includes("trm"));
    assert.ok(result.strategies.includes("tree_of_thoughts"));
    assert.equal(result.locked.length, 0, "No strategies should be locked");
  });
});

describe("MCP Protocol (stdio transport)", () => {
  before(setupTestHome);
  after(cleanupTestHome);

  it("should respond to initialize request", async () => {
    const response = await mcpRequest({
      jsonrpc: "2.0",
      id: 1,
      method: "initialize",
      params: {},
    });
    assert.ok(response, "Should receive a response");
    assert.equal(response.id, 1);
    assert.ok(response.result);
    assert.equal(response.result.protocolVersion, "2024-11-05");
    assert.ok(response.result.capabilities);
    assert.ok(response.result.serverInfo);
    assert.equal(response.result.serverInfo.name, "ai-prd-generator");
  });

  it("should list tools via tools/list", async () => {
    const response = await mcpRequest({
      jsonrpc: "2.0",
      id: 2,
      method: "tools/list",
      params: {},
    });
    assert.ok(response);
    assert.ok(response.result);
    assert.ok(Array.isArray(response.result.tools));
    const toolNames = response.result.tools.map((t) => t.name);
    assert.ok(toolNames.includes("check_health"));
    assert.ok(toolNames.includes("get_config"));
    assert.ok(toolNames.includes("list_available_strategies"));
    assert.ok(!toolNames.includes("validate_license"), "validate_license should be removed");
    assert.ok(!toolNames.includes("activate_license"), "activate_license should be removed");
    assert.ok(!toolNames.includes("get_license_features"), "get_license_features should be removed");
  });

  it("should call check_health via tools/call", async () => {
    const response = await mcpRequest({
      jsonrpc: "2.0",
      id: 3,
      method: "tools/call",
      params: { name: "check_health", arguments: {} },
    });
    assert.ok(response);
    assert.ok(response.result);
    assert.ok(Array.isArray(response.result.content));
    const text = response.result.content[0].text;
    const parsed = JSON.parse(text);
    assert.equal(parsed.status, "ok");
  });

  it("should return error for unknown tool", async () => {
    const response = await mcpRequest({
      jsonrpc: "2.0",
      id: 4,
      method: "tools/call",
      params: { name: "nonexistent_tool", arguments: {} },
    });
    assert.ok(response);
    const text = response.result.content[0].text;
    const parsed = JSON.parse(text);
    assert.ok(parsed.error);
    assert.ok(parsed.error.includes("Unknown tool"));
  });

  it("should return method not found for unknown method", async () => {
    const response = await mcpRequest({
      jsonrpc: "2.0",
      id: 5,
      method: "unknown/method",
      params: {},
    });
    assert.ok(response);
    assert.ok(response.error);
    assert.equal(response.error.code, -32601);
  });
});
