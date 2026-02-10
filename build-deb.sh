#!/usr/bin/env bash

set -euo pipefail

VERSION="1.0.0"
PKG_NAME="pr-ship"
BUILD_DIR="build/${PKG_NAME}_${VERSION}"

rm -rf build/
mkdir -p "${BUILD_DIR}/DEBIAN"
mkdir -p "${BUILD_DIR}/usr/bin"
mkdir -p "${BUILD_DIR}/usr/share/pr-ship/lang"

install -m 755 bin/pr-ship "${BUILD_DIR}/usr/bin/pr-ship"

for lang_file in lib/pr-ship/lang/*.sh; do
  install -m 644 "$lang_file" "${BUILD_DIR}/usr/share/pr-ship/lang/$(basename "$lang_file")"
done

cat > "${BUILD_DIR}/DEBIAN/control" <<EOF
Package: ${PKG_NAME}
Version: ${VERSION}
Section: devel
Priority: optional
Architecture: all
Depends: bash (>= 4.0), gh
Maintainer: Gabriel Rodrigues <gabsrodrigues-dev@users.noreply.github.com>
Homepage: https://github.com/gabsrodrigues-dev/pr-ship
Description: Create and merge GitHub PRs from the terminal
 pr-ship is a CLI tool that creates a Pull Request on GitHub
 and immediately merges it, all from your terminal.
 Supports multi-language, configurable defaults for owner,
 branches, PR title and body.
EOF

dpkg-deb --build "${BUILD_DIR}"

echo ""
echo "Package built: build/${PKG_NAME}_${VERSION}.deb"
echo ""
echo "Install with: sudo dpkg -i build/${PKG_NAME}_${VERSION}.deb"
echo "Or add to a PPA for apt-get distribution."
