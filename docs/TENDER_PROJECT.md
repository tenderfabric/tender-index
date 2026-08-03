# Tender Project artifacts

Tender Index is being developed by **Tender Fabric** as a focused fork of
`DeusData/codebase-memory-mcp`. The upstream engine supplies the local code
graph, hybrid search, MCP server, and compressed SQLite artifact. Tender's
project layer makes that artifact safe to build in CI, address by source
commit, verify, and load without running the upstream installer or editing any
agent configuration.

The repository owner is `tenderfabric`; no other account, organization,
credential, or repository is part of the design.

## What is in the open project layer

- one repository at one Git commit;
- a compressed local code graph plus explicit metadata;
- a SHA-256 binding from metadata to the exact compressed payload;
- a detached output path, so CI does not add generated files to the source
  checkout;
- verified loading when the artifact's commit is an ancestor of the checkout;
- an incremental local pass over the checkout, which acts as the working-tree
  or pull-request overlay;
- an OCI/GHCR recipe that stores each result under `sha-<commit>`.

## What is deliberately not here

This layer does not implement Tender Node federation, source grants,
cross-node fan-out, coverage receipts, ambiguous identity bridges, billing,
provider credentials, or private transport. It also does not edit Claude,
Codex, Cursor, Devin, or other client configuration. Those boundaries keep the
open indexing shell useful without copying private Tender Node/Fabric code into
the fork.

## Local use

Build the engine:

```bash
scripts/build.sh
```

Build a detached artifact for a clean checkout:

```bash
scripts/tender-project.sh build \
  --repo /path/to/project \
  --output /tmp/project-index
```

The command uses a temporary cache and writes only:

```text
/tmp/project-index/.codebase-memory/graph.db.zst
/tmp/project-index/.codebase-memory/artifact.json
```

Verify it without loading:

```bash
scripts/tender-project.sh verify \
  --artifact-root /tmp/project-index \
  --repo /path/to/project
```

Load the verified base and apply the selected checkout as an incremental local
overlay:

```bash
scripts/tender-project.sh load \
  --repo /path/to/project \
  --artifact-root /tmp/project-index
```

Loading fails closed if the payload digest is wrong or if the recorded source
commit is not an ancestor of the checkout. The command invokes only the
one-shot CLI; it does not install hooks, background services, skills, or MCP
entries.

## GitHub Actions and GHCR

This repository proves the path on every `main` commit through
[`project-index.yml`](../.github/workflows/project-index.yml), publishing its
own verified index to `ghcr.io/tenderfabric/tender-index-project-index` under a
`sha-<source-commit>` tag.

[`tender-index.yml.example`](../.github/tender-index.yml.example) is an inactive
template for a source repository. Its Tender Index checkout is pinned to a
reviewed immutable commit from the public `tenderfabric/tender-index`
repository; update that pin deliberately when adopting a newer engine.

The workflow builds the project index from a clean GitHub checkout and pushes
the two artifact files as one OCI artifact to:

```text
ghcr.io/<owner>/<repository>-tender-index:sha-<source-commit>
```

Keep the GHCR package private when the source repository is private. The graph
is derived from source code; it is not safe to expose merely because it is not
the source tree itself.

Pulling is intentionally an explicit act. With ORAS installed:

```bash
mkdir -p /tmp/project-index/.codebase-memory
oras pull ghcr.io/OWNER/REPOSITORY-tender-index:sha-COMMIT \
  -o /tmp/project-index/.codebase-memory
scripts/tender-project.sh load \
  --repo /path/to/project \
  --artifact-root /tmp/project-index
```

## Upstream attribution

The fork remains under the upstream MIT license and preserves its copyright
and notices. Tender Fabric's additions do not erase or replace that
attribution.
