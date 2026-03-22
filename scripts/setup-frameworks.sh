#!/bin/bash
# setup-frameworks.sh — Decrypt encrypted XCFrameworks for building
# Usage: ./scripts/setup-frameworks.sh
set -euo pipefail

# Note: This script is designed for the PUBLIC repo (ai-prd-generator) where it lives at scripts/
# In the private repo, use `make decrypt` instead
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENCRYPTED_DIR="$REPO_ROOT/frameworks/encrypted"
OUTPUT_DIR="$REPO_ROOT/frameworks"
PACKAGES_DIR="$REPO_ROOT/packages"

echo "═══════════════════════════════════════════════════════"
echo "  AIPRD Framework Setup"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check encrypted frameworks
if [ ! -d "$ENCRYPTED_DIR" ]; then
    echo "❌ Encrypted frameworks not found at: $ENCRYPTED_DIR"
    exit 1
fi

echo "  Decrypting frameworks..."
echo ""

# Compile and run decryption
swiftc -o /tmp/aiprd-decrypt "$REPO_ROOT/scripts/decrypt-frameworks.swift" -framework IOKit 2>/dev/null
ENCRYPTED_DIR="$ENCRYPTED_DIR" OUTPUT_DIR="$OUTPUT_DIR" PACKAGES_DIR="$PACKAGES_DIR" /tmp/aiprd-decrypt

echo ""
echo "  Frameworks ready at: $OUTPUT_DIR/"
if [ -d "$PACKAGES_DIR/AIPRDVisionEngineApple" ]; then
    echo "  Source packages at:  $PACKAGES_DIR/"
fi
echo "  You can now build with: swift build --package-path library"
echo "═══════════════════════════════════════════════════════"
