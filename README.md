# Tender Index

> **Tender Index is a fork of
> [`DeusData/codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp),
> originally developed by DeusData and released under the MIT License.**

**Give every AI coding tool an already-built understanding of your codebase.**

Tender Index turns a Git repository into a reusable code map that people,
Claude, Codex, and other MCP-compatible tools can query instead of rediscovering
the project in every session.

## What it does

- Finds symbols and source with BM25 full-text search.
- Supports local semantic vector queries without sending source code to an
  embedding API.
- Maps definitions, calls, imports, routes, references, and dependencies.
- Traces execution paths and returns cited source snippets.
- Shows architecture, package boundaries, services, hotspots, and deterministic
  Leiden communities.
- Reports indexing coverage so an answer can disclose what the map may have
  missed.

## What comes from the parent project

[`DeusData/codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp)
provides the substantial technical foundation: the high-performance C engine,
tree-sitter language parsers, BM25 index, local semantic search, code graph,
graph store, structural and semantic query tools, architecture analysis, and
core MCP server.

That project provides a sophisticated **code graph**. It does not include the
separate Graphify system, and Tender Index does not represent it as if it did.

## What Tender Fabric adds

Tender turns that engine into a durable project memory that can be built once
and safely reused:

- one `tender-index` command with an isolated Tender installation;
- a private project artifact tied to an exact Git commit and SHA-256 digest;
- automatic generation in GitHub Actions and private distribution through
  OCI/GHCR;
- a verified base index with a fast overlay for the current branch or pull
  request;
- a versioned Map contract that records its producer and the provenance of each
  kind of signal; and
- explicit MCP setup that never silently rewrites an AI client's configuration.

See [UPSTREAM.md](UPSTREAM.md) for the complete attribution and the precise
boundary between upstream work and Tender additions.

Your graph is derived from your source code. Keep its package private whenever
the repository is private.

## Install Tender Index

The current friend preview installs from source on macOS and Linux:

```bash
git clone https://github.com/tenderfabric/tender-index.git
cd tender-index
./install.sh
```

This installs `tender-index` under `~/.local/bin` and the underlying engine
under `~/.local/libexec/tender-index`. It does **not** run the upstream
installer, edit agent configuration, install hooks, or start a background
service.

If `~/.local/bin` is not already on your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Confirm the boundary:

```bash
tender-index doctor
```

## Use it in a project

From a Git checkout:

```bash
# Build a verified artifact for the current clean commit.
tender-index build

# Load that base and apply the current checkout as a local overlay.
tender-index load

# Search source with graph context.
tender-index search "where is request routing decided?"

# See the project map: communities, hotspots, layers, services and boundaries.
tender-index map
```

By default, artifacts and active indexes live under
`~/.cache/tender-index`. Override that with `TENDER_INDEX_CACHE_DIR`.

### Add the GitHub workflow

```bash
tender-index init
git diff -- .github/workflows/tender-index.yml
```

`init` is deliberately the only setup command that changes the repository. It
writes one workflow pinned to the exact Tender Index revision you installed.
After you review and commit it, each `main` commit produces a private artifact
at:

```text
ghcr.io/<owner>/<repository>-tender-index:sha-<commit>
```

The workflow never commits generated graph files to your source branch.

## Connect an AI tool

Tender Index speaks MCP over standard input/output:

```bash
tender-index mcp
```

Use that command as the MCP server command in the client you choose and name
the server `tender-index`. Tender does not silently install itself into every
agent. The connection is explicit, inspectable, and removable in the client
that owns it.

The MCP surface includes structural search, call-path tracing, cited snippets,
architecture, graph queries, coverage checks, and change detection. `map` is
the human-readable entrance to the same project model.

## What the Map means

Tender Index does not ask a language model to invent relationships in your
code. Its default map is deterministic:

| Signal | Meaning |
| --- | --- |
| Symbols and definitions | Extracted from parsed source. |
| Calls, imports, routes and references | Extracted relationships with source locations. |
| Hotspots | Nodes with measured graph fan-in/fan-out. |
| Layers and package boundaries | Derived from observed direction and density of edges. |
| Communities | Deterministic Leiden clustering over the project graph. |
| Coverage | Files or ranges the parser could not completely represent. |

This is a deterministic code map built from the parent engine's extracted
graph. It is not the separate Graphify semantic-enrichment pipeline, and it
does not present inferred project relationships as source truth.

## The artifact lifecycle

```text
Git commit
   │
   ├── GitHub Actions ──> private commit-addressed artifact
   │                              │
   └── local checkout ────────────┤ verify digest + ancestry
                                  ▼
                         base graph + local overlay
                                  │
                         CLI / Map / MCP tools
```

The loader fails closed if the compressed graph digest is wrong or the
artifact commit is not an ancestor of the checkout. A pull request does not
need a second full index: Tender loads the reviewed base and incrementally
applies the checked-out difference.

## Public and private boundaries

This repository is the open, single-project indexing layer. It intentionally
does **not** contain Tender Node federation, source grants, signed usage
receipts, cross-machine fan-out, billing, provider credentials, or private
transport. Those belong to the private Tender Node/Fabric layer, where indexes
can later be composed without publishing source or graph custody.

See [Tender project artifacts](docs/TENDER_PROJECT.md) for the artifact format
and operational details, and [fork boundary](TENDER_FORK.md) for the line
between this repository and the private product.

## Credits and attribution

Tender Index is a focused fork of the MIT-licensed
[`DeusData/codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp).
That project supplies the high-performance C engine, tree-sitter language
parsers, graph store, structural queries, and core MCP implementation. Tender
Fabric preserves its copyright, MIT license, and notices in
[LICENSE](LICENSE), [UPSTREAM.md](UPSTREAM.md), and
[THIRD_PARTY.md](THIRD_PARTY.md).

Tender Fabric's work is the Tender install and command surface, verified
project-artifact lifecycle, GitHub/OCI distribution, local overlay contract,
and the product boundary described above. We do not claim to have invented the
underlying code graph.

## Status

Tender Index is an early public developer preview. macOS and Linux are the
supported install path today. The underlying engine has broader platform
support, but a Tender-branded Windows installer will not be advertised until
it passes the same install and no-config-mutation gates.

Licensed under MIT. Contributions must preserve upstream attribution and the
public/private boundary.
