#!/usr/bin/env bash

set -euo pipefail

export ERL_FLAGS="+B d"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cleanup() {
	echo
	echo "Cleaning up..."
}

trap cleanup EXIT SIGINT SIGTERM

echo "Running dev..."
echo
echo "Starting client..."
echo
cd "$ROOT/apps/client"
./build.sh | sed 's/^/[client] /'
echo
echo "Starting server..."
echo
cd "$ROOT/apps/server" 
gleam run 2>&1 | sed 's/^/[server] /'

