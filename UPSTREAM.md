# Upstream attribution

Tender Index is a fork of
[`DeusData/codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp).
The original project was developed by **DeusData** and released under the MIT
License.

- **Upstream project:** `DeusData/codebase-memory-mcp`
- **Upstream copyright:** Copyright (c) 2025 DeusData
- **License:** MIT; the original copyright and permission notice are preserved
  verbatim in [LICENSE](LICENSE)

Substantial parts of this repository come from that project, including the
high-performance C engine, tree-sitter parser integration, graph store,
language extraction, structural and semantic query implementation, and core
MCP server. Tender Fabric is grateful to DeusData and the upstream contributors
for making that foundation available.

## What Tender Fabric adds

Tender Fabric's public additions are deliberately narrower than the engine:

| Tender addition | Purpose |
| --- | --- |
| `tender-index` command and installer | A single Tender-owned interface that does not invoke the upstream installer or silently alter AI-client configuration. |
| Project artifact contract | Commit-addressed artifacts bound to source ancestry and a SHA-256 payload digest. |
| GitHub Actions and GHCR lifecycle | Build once for a reviewed commit and distribute the graph separately from the source branch. |
| Verified base plus local overlay | Reuse the reviewed base while incrementally applying a branch or pull-request checkout. |
| Tender Map contract | Versioned producer/disposition metadata around architecture, hotspots, paths, boundaries, and deterministic communities. |
| Public/private boundary | A clean single-project layer that excludes Tender Node federation, grants, receipts, credentials, billing, and transport. |

Tender Fabric does not claim to have invented the underlying code graph,
parsers, graph database, or core MCP implementation. Changes made in this fork
remain available under the same MIT License, with upstream attribution intact.

Additional third-party component notices are recorded in
[THIRD_PARTY.md](THIRD_PARTY.md) and beside vendored source.
