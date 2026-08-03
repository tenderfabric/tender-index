# Tender Index fork and attribution boundary

This working fork is owned and developed by **Tender Fabric** (`tenderfabric`).
It is based on the MIT-licensed
[`DeusData/codebase-memory-mcp`](https://github.com/DeusData/codebase-memory-mcp)
project and preserves the upstream license and attribution.

The detailed upstream/Tender contribution split is recorded in
[`UPSTREAM.md`](UPSTREAM.md). The original DeusData copyright and MIT grant are
preserved verbatim in [`LICENSE`](LICENSE).

The public scope is the Tender-native install and command surface, curated
single-project Map, verified project-artifact lifecycle, CI/OCI distribution,
and local checkout overlay documented in
[`docs/TENDER_PROJECT.md`](docs/TENDER_PROJECT.md).

The high-performance C graph engine remains attributed upstream and is an
internal implementation detail of the Tender install. Private Tender Node and
Tender Fabric mechanisms—federation, grants, receipts, billing, credentials,
and transport—remain outside this repository.
