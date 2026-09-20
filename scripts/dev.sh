#!/usr/bin/env bash

set -euo pipefail

export ERL_FLAGS="+B d"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cleanup() {
	echo
	echo "Cleaning up..."
	kill "$CLIENT_PID" 2>/dev/null || true
}

trap cleanup EXIT SIGINT SIGTERM

echo "Running dev..."
echo
echo "Starting client..."
echo
(
	cd "$ROOT/apps/client"
	gleam run -m lustre/dev start 2>&1 | sed 's/^/[client] /'
) &
CLIENT_PID=$!
echo
echo "Starting server..."
echo
cd "$ROOT/apps/server" 
gleam run 2>&1 | sed 's/^/[server] /'

