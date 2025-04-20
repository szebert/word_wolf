#!/usr/bin/env bash
set -euo pipefail

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Extract version from pubspec.yaml
VERSION=$(grep '^version:' "$ROOT_DIR/pubspec.yaml" | awk '{print $2}')
if [[ -z "$VERSION" ]]; then
  echo "❌ Could not find version in pubspec.yaml" >&2
  exit 1
fi

# Generate timestamp (YYYYMMDD_HHMM)
TIMESTAMP=$(date +%Y%m%d_%H%M)

# Prepare output directory
OUTDIR="$ROOT_DIR/symbol-archives/ios/${VERSION}_${TIMESTAMP}"
mkdir -p "$OUTDIR"

# Run the build
echo "🔨 Building iOS IPA and splitting debug info to $OUTDIR"
flutter build ipa \
  --obfuscate \
  --split-debug-info="$OUTDIR"

echo "✅ iOS symbols saved to: $OUTDIR"
