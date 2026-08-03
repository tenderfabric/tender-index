# Security Policy

## What Tender Index accesses

Tender Index reads the Git repository you explicitly invoke it against and
writes derived indexes and verified project artifacts under
`~/.cache/tender-index` by default. `TENDER_INDEX_CACHE_DIR` can move that
storage elsewhere.

The Tender installer:

- installs the `tender-index` command and its engine under the chosen prefix;
- does not edit Claude, Codex, Cursor, Devin, or another agent's configuration;
- does not install repository hooks;
- does not start a permanent daemon; and
- does not upload source, queries, or graph contents.

`tender-index init` is the one explicit repository mutation. It writes a pinned
GitHub Actions workflow at `.github/workflows/tender-index.yml`. That workflow
publishes a commit-addressed artifact to the repository owner's private GHCR
namespace. Treat a graph artifact as private whenever its source is private.

`tender-index mcp` exposes the analysis tool profile over stdio. The client that
launches it owns the process lifetime. Connecting a client is an explicit client
configuration step; Tender Index does not perform it automatically.

The embedded engine may use a short-lived worker for an individual command. It
must exit with that command and is not an installed background service.

## Reporting a vulnerability

Do not open a public issue for a vulnerability and do not attach proprietary
source, a private graph artifact, credentials, or secrets.

Use GitHub's private vulnerability reporting for this repository:

<https://github.com/tenderfabric/tender-index/security/advisories/new>

Include a minimal synthetic reproduction, affected revision, platform, impact,
and any suggested mitigation. Reports involving filesystem-boundary escapes,
command execution, artifact verification bypass, unintended network egress,
credential exposure, or installer mutation are particularly important.

## Supply-chain and attribution boundary

Tender Index vendors an MIT-licensed upstream engine and other permissively
licensed components. Their notices and pinned provenance remain in
[THIRD_PARTY.md](THIRD_PARTY.md) and the vendored directories. A Tender-branded
installer must never silently invoke an upstream installer or advertise an
upstream package as though it were Tender Index.

No security claim in this document applies to the separate private Tender
Node/Fabric product.
