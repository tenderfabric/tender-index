# Tender Index project artifacts

A Tender project index is a reusable map of one Git repository at one commit.
It is built outside the source checkout, bound to the compressed graph by
SHA-256, and addressed by the source commit that produced it.

## Why a project artifact exists

An AI tool should not spend the beginning of every session rediscovering the
same architecture. A team also should not check a generated database into its
main source branch. Tender separates those concerns:

1. CI checks out a clean commit and builds the base map once.
2. The graph and metadata are published as a private OCI artifact.
3. A local Tender Index verifies the payload and source ancestry.
4. The current branch or pull request is applied as an incremental overlay.
5. CLI and MCP tools query the combined local view.

## Artifact contents

The detached artifact currently contains:

```text
.codebase-memory/graph.db.zst
.codebase-memory/artifact.json
```

`.codebase-memory` is an internal compatibility directory inherited from the
engine; users install and operate the product exclusively through
`tender-index`. The metadata records the project, source commit, graph schema,
node/edge counts, original and compressed sizes, and SHA-256 of the exact
compressed payload.

The artifact is derived from source and can reveal architecture even though it
does not contain a normal source checkout. Keep it private when the repository
is private.

## Local lifecycle

```bash
tender-index build
tender-index verify
tender-index load
tender-index status
tender-index map
```

Defaults are computed from the current Git checkout. Advanced callers can
select explicit paths:

```bash
tender-index build \
  --repo /path/to/project \
  --output /tmp/project-index

tender-index verify \
  --repo /path/to/project \
  --artifact-root /tmp/project-index

tender-index load \
  --repo /path/to/project \
  --artifact-root /tmp/project-index
```

Build refuses a dirty checkout for a publishable base. Verify rejects a digest
mismatch and, when a repository is supplied, rejects an artifact commit that
is not an ancestor of the selected checkout. Load repeats both checks before
importing and then applies the local checkout incrementally.

No lifecycle command edits AI-client configuration.

## GitHub Actions and GHCR

Run `tender-index init` inside a source repository. It writes
`.github/workflows/tender-index.yml` pinned to the exact public Tender Index
revision that installed it. The workflow builds a detached artifact and pushes
the two files as one OCI artifact:

```text
ghcr.io/<owner>/<repository>-tender-index:sha-<source-commit>
```

The media types are:

```text
application/vnd.tender.index.project.v1
application/vnd.tender.index.graph.v1+zstd
application/vnd.tender.index.metadata.v1+json
```

The source workflow is granted only `contents: read` and `packages: write`.
The Tender engine checkout and third-party actions are pinned to reviewed
commits.

## Map and retrieval

The base engine persists parsed symbols and typed relationships. Tender's Map
curates the architecture surface used as project memory:

- languages, packages and entry points;
- routes and cross-service links;
- hotspots and package boundaries;
- inferred architectural layers with their measured reason; and
- deterministic Leiden communities with membership and cohesion.

Search, path tracing, snippets, graph queries, change detection, and coverage
remain available through the MCP doorway. Coverage metadata stays separate
from graph facts so an incomplete parse cannot silently look complete.

## Deliberate boundary

This public layer is one source repository and one project artifact. Tender
Node federation, grants, cross-node coverage, ambiguous identity bridges,
signed tool receipts, billing, credentials, and transport are not implemented
here. The open project artifact is designed to feed that private layer without
embedding private Fabric code in this repository.

## Attribution

The C engine is based on `DeusData/codebase-memory-mcp` under MIT. Tender
Fabric preserves the upstream license and notices. The artifact lifecycle,
Tender command/install surface, and project distribution contract are Tender
Fabric additions.
