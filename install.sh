#!/usr/bin/env bash
# Tender Index source installer for macOS and Linux.
# It installs only Tender Index. It never invokes the upstream installer and
# never edits Claude, Codex, Cursor, Devin, or another client's configuration.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

if [[ ! -x "$ROOT/scripts/tender-index" || ! -f "$ROOT/Makefile.cbm" ]]; then
    printf '%s\n' \
        'Tender Index must currently be installed from a checked-out source tree:' \
        '  git clone https://github.com/tenderfabric/tender-index.git' \
        '  cd tender-index' \
        '  ./install.sh' >&2
    exit 2
fi

"$ROOT/scripts/tender-index" install "$@"
