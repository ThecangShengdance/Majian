#!/bin/bash
# 无头验证：Payload -> 纯 Swift 编码器 -> PNG -> Vision 解码
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p .build/verify .build/tmp .build/modulecache
TMPDIR="$PWD/.build/tmp" \
CLANG_MODULE_CACHE_PATH="$PWD/.build/modulecache" \
swiftc -O \
  Sources/Core/Payload.swift \
  Sources/Core/QRCodeEngine.swift \
  Sources/Core/Vendor/*.swift \
  Tests/main.swift \
  -o .build/verify/majian-verify

.build/verify/majian-verify
