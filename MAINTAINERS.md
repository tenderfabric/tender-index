# Maintainers

Tender Index is maintained by [`@tenderfabric`](https://github.com/tenderfabric).
Tender Fabric is the final authority for roadmap, merge, security, release,
workflow, package publication, and public/private-boundary decisions.

All pull requests require Tender Fabric review. Review responsibility may be
delegated later, but delegation does not imply release or security-advisory
authority unless this file and repository settings say so explicitly.

High-risk changes always require owner review:

- MCP tool behavior or externally visible artifact contracts;
- filesystem, process, or network access;
- installers, updaters, package publication, or CI credentials;
- vendored dependencies and generated parsers;
- security policy, branch protection, CODEOWNERS, or licensing; and
- any mechanism reserved for the private Tender Node/Fabric layer.

The inherited engine has extensive upstream history and attribution. Technical
ownership of this fork does not erase that provenance; see [THIRD_PARTY.md](THIRD_PARTY.md)
and [TENDER_FORK.md](TENDER_FORK.md).
