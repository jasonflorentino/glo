#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR" || exit 1

OUT_DIR="$SCRIPT_DIR/../server/priv/static"

gleam run -m lustre/dev build --outdir="$OUT_DIR" --no-html=true
