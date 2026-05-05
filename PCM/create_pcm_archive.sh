#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "❌ ERROR: VERSION not provided"
  exit 1
fi

VERSION="${VERSION//\//-}"

echo "=============================="
echo "KiCAD PCM build"
echo "Version: $VERSION"
echo "PWD: $(pwd)"
echo "=============================="

# -------------------------
# Cleanup
# -------------------------
rm -rf PCM/archive
rm -f PCM/KiCAD-PCM-*.zip

# -------------------------
# Create structure
# -------------------------
mkdir -p PCM/archive/plugins
mkdir -p PCM/archive/resources

# -------------------------
# Validate required files
# -------------------------
if [[ ! -f "PCM/metadata.json" ]]; then
  echo "❌ Missing PCM/metadata.json"
  exit 1
fi

# -------------------------
# Copy core files
# -------------------------
cp PCM/metadata.json PCM/archive/metadata.json

if [[ -f "PCM/icon.png" ]]; then
  cp PCM/icon.png PCM/archive/resources/icon.png
fi

# Copy plugin sources (ONLY from PCM/)
find PCM -maxdepth 1 -name "*.py" -exec cp {} PCM/archive/plugins/ \;
find PCM -maxdepth 1 -name "*.png" -exec cp {} PCM/archive/plugins/ \;

# -------------------------
# Version file
# -------------------------
echo "$VERSION" > PCM/archive/plugins/VERSION

# -------------------------
# Patch metadata
# -------------------------
METADATA="PCM/archive/metadata.json"

sed -i "s|VERSION_HERE|$VERSION|g" "$METADATA"

# remove placeholders if present
sed -i "/SHA256_HERE/d" "$METADATA"
sed -i "/DOWNLOAD_SIZE_HERE/d" "$METADATA"
sed -i "/DOWNLOAD_URL_HERE/d" "$METADATA"
sed -i "/INSTALL_SIZE_HERE/d" "$METADATA"

# -------------------------
# Create ZIP
# -------------------------
cd PCM/archive
zip -r "../KiCAD-PCM-${VERSION}.zip" . > /dev/null
cd ../..

ZIP_FILE="PCM/KiCAD-PCM-${VERSION}.zip"

if [[ ! -f "$ZIP_FILE" ]]; then
  echo "❌ ZIP creation failed"
  exit 1
fi

echo "✅ ZIP created: $ZIP_FILE"

# -------------------------
# Metadata for CI
# -------------------------
DOWNLOAD_SHA256=$(sha256sum "$ZIP_FILE" | awk '{print $1}')
DOWNLOAD_SIZE=$(stat -c%s "$ZIP_FILE")
INSTALL_SIZE=$(unzip -l "$ZIP_FILE" | tail -1 | awk '{print $1}')

DOWNLOAD_URL="https://github.com/KoenLammers/KiCAD-EasyEDA-Parts-V2/releases/download/${VERSION}/KiCAD-PCM-${VERSION}.zip"

echo "VERSION=$VERSION" >> "$GITHUB_ENV"
echo "DOWNLOAD_SHA256=$DOWNLOAD_SHA256" >> "$GITHUB_ENV"
echo "DOWNLOAD_SIZE=$DOWNLOAD_SIZE" >> "$GITHUB_ENV"
echo "DOWNLOAD_URL=$DOWNLOAD_URL" >> "$GITHUB_ENV"
echo "INSTALL_SIZE=$INSTALL_SIZE" >> "$GITHUB_ENV"

echo "=============================="
echo "Build complete"
echo "=============================="