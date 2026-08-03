# Contributing to Tender Index

Tender Index is the public, single-project indexing layer maintained by Tender
Fabric. Contributions are welcome when they preserve three boundaries:

1. `tender-index` is the user-facing command and install path.
2. Index artifacts for private repositories remain private.
3. Tender Node federation, grants, receipts, billing, credentials, and private
   transport do not enter this public repository.

The indexing engine is a focused fork of the MIT-licensed
[`DeusData/codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp).
Preserve its copyright, license, notices, and provenance when changing inherited
code.

## Build and test

Prerequisites are a C compiler, `make`, `zlib`, and Git. On macOS,
`xcode-select --install` supplies the compiler. On Debian/Ubuntu, install
`build-essential` and `zlib1g-dev`.

```bash
git clone https://github.com/tenderfabric/tender-index.git
cd tender-index
scripts/build.sh
make -f Makefile.cbm test-focused TEST_SUITES='artifact mcp'
```

For a product-level check, use a disposable Git repository:

```bash
./install.sh --prefix /tmp/tender-index-prefix
PATH="/tmp/tender-index-prefix/bin:$PATH" tender-index doctor
```

The installer must not edit Claude, Codex, Cursor, Devin, or any other agent
configuration. Only `tender-index init` may modify a target repository, and it
may write only `.github/workflows/tender-index.yml` after explicit invocation.

## Pull requests

- Open an issue before a substantial behavioral or contract change.
- Keep each pull request focused and add a regression test for new behavior.
- Run `git diff --check`, the relevant tests, and an end-to-end Tender command
  proof before requesting review.
- Never include private repositories, source, graph artifacts, credentials,
  evidence material, or Tender's private implementation.
- Preserve the public/private boundary in [TENDER_FORK.md](TENDER_FORK.md).
- Sign off commits as required by [DCO](DCO).

Changes to artifact formats, MCP tools, installers, source access, network
behavior, CI publication, or vendored dependencies require Tender Fabric review.
