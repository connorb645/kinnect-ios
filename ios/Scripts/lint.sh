#!/usr/bin/env bash
set -euo pipefail

echo "[lint] Running swiftlint/swift-format if available..."
if command -v swiftlint >/dev/null 2>&1; then
  swiftlint || true
else
  echo "[lint] swiftlint not installed. Skipping."
fi

if command -v swift-format >/dev/null 2>&1; then
  swift-format format --in-place --recursive . || true
else
  echo "[lint] swift-format not installed. Skipping."
fi

echo "[lint] Done."

