#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo
echo script dir $SCRIPT_DIR
cd "$SCRIPT_DIR" || exit 1
echo
echo building gleam
gleam run -m lustre/dev build --no-html=true
echo
echo building stylesheet
tailwindcss -i ./src/client.css -o ../server/priv/static/client.css
echo
echo done
