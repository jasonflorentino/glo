#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

throw() {
	echo "Failed"; 
	exit 1;
}

echo Running dev
echo
echo Building client
echo
"$ROOT/apps/client/build.sh" || throw
echo
echo Starting server
echo
(cd "$ROOT/apps/server" && gleam run) || throw
echo
echo Bye bye

