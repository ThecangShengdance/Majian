#!/bin/bash
# 构建 Majian.app 到 Dist/ 目录
set -euo pipefail
cd "$(dirname "$0")"

CONFIG="${1:-Release}"
DERIVED=".build/dd"
OUT="Dist"

mkdir -p "$DERIVED" "$OUT"

xcodebuild \
  -project Majian.xcodeproj \
  -scheme Majian \
  -configuration "$CONFIG" \
  -derivedDataPath "$DERIVED" \
  -destination 'platform=macOS' \
  OTHER_SWIFT_FLAGS="-disable-sandbox" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=YES \
  build

rm -rf "$OUT/Majian.app"
cp -R "$DERIVED/Build/Products/$CONFIG/Majian.app" "$OUT/Majian.app"

# MIT 要求随分发副本附带版权与许可声明；放进 .app 内，而不是只放在仓库里。
cp LICENSE "$OUT/Majian.app/Contents/Resources/LICENSE"
cp THIRD_PARTY_NOTICES.md "$OUT/Majian.app/Contents/Resources/THIRD_PARTY_NOTICES.md"

xattr -cr "$OUT/Majian.app" 2>/dev/null || true
# Finder 会在 bundle 根目录补回 FinderInfo，导致 codesign 报 “resource fork ... not allowed”。
xattr -d com.apple.FinderInfo "$OUT/Majian.app" 2>/dev/null || true
xattr -d 'com.apple.fileprovider.fpfs#P' "$OUT/Majian.app" 2>/dev/null || true
codesign --force --deep --sign - "$OUT/Majian.app"
codesign --verify --deep --strict "$OUT/Majian.app"

VERSION=$(plutil -extract CFBundleShortVersionString raw "$OUT/Majian.app/Contents/Info.plist")

# 从干净副本打包，并排除扩展属性，避免 FinderInfo 混进 zip 破坏签名。
PKG=".build/package"
rm -rf "$PKG"
mkdir -p "$PKG"
ditto "$OUT/Majian.app" "$PKG/Majian.app"
xattr -cr "$PKG/Majian.app" 2>/dev/null || true
codesign --verify --deep --strict "$PKG/Majian.app"
ditto -c -k --keepParent --norsrc --noextattr "$PKG/Majian.app" "$OUT/Majian-$VERSION.zip"
rm -rf "$PKG"

echo "✅ 已生成: $(pwd)/$OUT/Majian.app"
echo "✅ 已生成: $(pwd)/$OUT/Majian-$VERSION.zip"
echo "   安装：解压 zip，把 Majian.app 拖到「应用程序」文件夹后双击运行"
