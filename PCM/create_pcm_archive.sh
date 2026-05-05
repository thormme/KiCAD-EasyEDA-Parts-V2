#!/usr/bin/env bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "ERROR: VERSION not provided"
  exit 1
fi

echo "Clean up old files"
rm -f PCM/*.zip
rm -rf PCM/archive

echo "Create folder structure for ZIP"
mkdir -p PCM/archive/plugins
mkdir -p PCM/archive/resources

echo "Copy files to destination"

# store version
echo "$VERSION" > PCM/archive/plugins/VERSION

# safe copies
cp *.py PCM/archive/plugins/ 2>/dev/null || true
cp *.png PCM/archive/plugins/ 2>/dev/null || true

cp PCM/icon.png PCM/archive/resources/ 2>/dev/null || true
cp PCM/metadata.json PCM/archive/metadata.json

echo "Modify archive metadata.json"

# FIXED sed (safe delimiter)
sed -i "s|VERSION_HERE|$VERSION|g" PCM/archive/metadata.json

# ensure correct KiCad 6 version format (this line is redundant but safe)
sed -i "s|\"kicad_version\": \"6.0\",|\"kicad_version\": \"6.0\"|g" PCM/archive/metadata.json

# remove placeholders safely
sed -i "/SHA256_HERE/d" PCM/archive/metadata.json
sed -i "/DOWNLOAD_SIZE_HERE/d" PCM/archive/metadata.json
sed -i "/DOWNLOAD_URL_HERE/d" PCM/archive/metadata.json
sed -i "/INSTALL_SIZE_HERE/d" PCM/archive/metadata.json

echo "Zip PCM archive"
cd PCM/archive
zip -r "../KiCAD-PCM-${VERSION}.zip" .
cd ../..

ZIP_FILE="PCM/KiCAD-PCM-${VERSION}.zip"

echo "Gather data for repo rebuild"

DOWNLOAD_SHA256=$(sha256sum "$ZIP_FILE" | awk '{print $1}')
DOWNLOAD_SIZE=$(stat -c%s "$ZIP_FILE")
INSTALL_SIZE=$(unzip -l "$ZIP_FILE" | tail -1 | awk '{print $1}')

DOWNLOAD_URL="https://github.com/KoenLammers/KiCAD-EasyEDA-Parts-V2/releases/download/${VERSION}/KiCAD-PCM-${VERSION}.zip"

echo "VERSION=$VERSION" >> "$GITHUB_ENV"
echo "DOWNLOAD_SHA256=$DOWNLOAD_SHA256" >> "$GITHUB_ENV"
echo "DOWNLOAD_SIZE=$DOWNLOAD_SIZE" >> "$GITHUB_ENV"
echo "DOWNLOAD_URL=$DOWNLOAD_URL" >> "$GITHUB_ENV"
echo "INSTALL_SIZE=$INSTALL_SIZE" >> "$GITHUB_ENV"