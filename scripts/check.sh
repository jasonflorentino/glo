#!/usr/bin/env bash

set -euo pipefail

echo "Checking all gleam projects"
echo

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find "$ROOT/apps" "$ROOT/packages" \
  -name gleam.toml \
  -not -path '*/build/*' \
  -print0 |
while IFS= read -r -d '' gleam_path; do
  project_dir="$(dirname "$gleam_path")"

  echo
  echo "Checking ${project_dir#"$ROOT/"}"

  (
    cd "$project_dir"
    gleam check
  )
done

echo
echo "Done"
