#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Running build..."
echo
echo "Building client..."
echo
	cd "$ROOT/apps/client"
	./build.sh | sed 's/^/[client] /'
echo
echo "Done"
