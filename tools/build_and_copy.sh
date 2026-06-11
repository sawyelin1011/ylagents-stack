#!/usr/bin/env bash
# =============================================================================
# Build & Copy Script for Kelivo
# =============================================================================
# Usage:
#   ./tools/build_and_copy.sh <platform> [mode]
#
# Platforms:  linux, android, web, macos, windows
# Modes:      debug (default), release, profile
#
# After a successful build, the script automatically copies the output files
# into <project>/build_output/ organized by version, platform, and mode.
#
# Examples:
#   ./tools/build_and_copy.sh linux debug
#   ./tools/build_and_copy.sh linux release
#   ./tools/build_and_copy.sh android release
#   ./tools/build_and_copy.sh web
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_OUTPUT_DIR="$PROJECT_DIR/build_output"
PUBSPEC="$PROJECT_DIR/pubspec.yaml"

# ---- Parse arguments ----
if [ $# -lt 1 ]; then
  echo "Usage: $0 <platform> [mode]" >&2
  echo "  platform: linux, android, web, macos, windows" >&2
  echo "  mode:     debug (default), release, profile" >&2
  exit 1
fi

PLATFORM="$1"
MODE="${2:-debug}"

# ---- Extract app version from pubspec.yaml ----
# Looks for line: version: 1.2.3+45
APP_VERSION=$(grep -E '^version:' "$PUBSPEC" | sed 's/version: *//' | tr -d '[:space:]')
if [ -z "$APP_VERSION" ]; then
  echo "Error: Could not extract version from pubspec.yaml" >&2
  exit 1
fi

# ---- Build config per platform ----
case "$PLATFORM" in
  linux)
    FLUTTER_BUILD_CMD="flutter build linux --$MODE"
    # After build, the bundle lives at: build/linux/x64/<mode>/bundle/
    OUTPUT_SRC="$PROJECT_DIR/build/linux/x64/$MODE/bundle"
    OUTPUT_NAME="kelivo-linux-$MODE"
    ;;
  android)
    if [ "$MODE" = "release" ]; then
      FLUTTER_BUILD_CMD="flutter build apk --release"
    else
      FLUTTER_BUILD_CMD="flutter build apk --debug"
    fi
    OUTPUT_SRC="$PROJECT_DIR/build/app/outputs/flutter-apk"
    OUTPUT_NAME="kelivo-android-$MODE"
    ;;
  web)
    FLUTTER_BUILD_CMD="flutter build web --$MODE"
    OUTPUT_SRC="$PROJECT_DIR/build/web"
    OUTPUT_NAME="kelivo-web-$MODE"
    ;;
  macos)
    FLUTTER_BUILD_CMD="flutter build macos --$MODE"
    if [ "$MODE" = "debug" ]; then
      OUTPUT_SRC="$PROJECT_DIR/build/macos/Build/Products/Debug"
    else
      OUTPUT_SRC="$PROJECT_DIR/build/macos/Build/Products/$MODE"
    fi
    OUTPUT_NAME="kelivo-macos-$MODE"
    ;;
  windows)
    FLUTTER_BUILD_CMD="flutter build windows --$MODE"
    OUTPUT_SRC="$PROJECT_DIR/build/windows/x64/runner/$MODE"
    OUTPUT_NAME="kelivo-windows-$MODE"
    ;;
  *)
    echo "Error: Unknown platform '$PLATFORM'. Use: linux, android, web, macos, windows" >&2
    exit 1
    ;;
esac

# ---- Run the flutter build ----
echo "=============================================="
echo " Kelivo Build"
echo " Platform : $PLATFORM"
echo " Mode     : $MODE"
echo " Version  : $APP_VERSION"
echo "=============================================="

cd "$PROJECT_DIR"

echo "Running: $FLUTTER_BUILD_CMD"
if ! $FLUTTER_BUILD_CMD; then
  echo "ERROR: Build failed." >&2
  exit 1
fi

echo ""
echo "Build succeeded."

# ---- Copy build output ----
DEST_DIR="$BUILD_OUTPUT_DIR/$APP_VERSION/$OUTPUT_NAME"

echo ""
echo "Copying output..."

# Remove previous copy for this version/platform/mode
rm -rf "$DEST_DIR"

case "$PLATFORM" in
  linux)
    # Copy the entire bundle (executable + lib/ + data/)
    mkdir -p "$(dirname "$DEST_DIR")"
    cp -a "$OUTPUT_SRC" "$DEST_DIR"
    echo "  Copied bundle: $OUTPUT_SRC -> $DEST_DIR"
    ;;
  android)
    mkdir -p "$DEST_DIR"
    cp -a "$OUTPUT_SRC"/*.apk "$DEST_DIR"/ 2>/dev/null || true
    # Also copy app bundle if available
    if [ -d "$PROJECT_DIR/build/app/outputs/bundle" ]; then
      cp -a "$PROJECT_DIR/build/app/outputs/bundle"/* "$DEST_DIR"/ 2>/dev/null || true
    fi
    APK_COUNT=$(find "$DEST_DIR" -name "*.apk" 2>/dev/null | wc -l)
    echo "  Copied $APK_COUNT APK(s) to: $DEST_DIR"
    ;;
  web)
    mkdir -p "$(dirname "$DEST_DIR")"
    cp -a "$OUTPUT_SRC" "$DEST_DIR"
    echo "  Copied web build: $OUTPUT_SRC -> $DEST_DIR"
    ;;
  macos)
    mkdir -p "$(dirname "$DEST_DIR")"
    cp -a "$OUTPUT_SRC"/*.app "$DEST_DIR"/ 2>/dev/null || true
    echo "  Copied macOS app to: $DEST_DIR"
    ;;
  windows)
    mkdir -p "$(dirname "$DEST_DIR")"
    cp -a "$OUTPUT_SRC" "$DEST_DIR"
    echo "  Copied Windows build: $OUTPUT_SRC -> $DEST_DIR"
    ;;
esac

echo ""
echo "=============================================="
echo " Done! Output location:"
echo "   $DEST_DIR"
echo "=============================================="