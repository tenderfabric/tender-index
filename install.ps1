$ErrorActionPreference = "Stop"

Write-Error @"
The Tender Index friend preview installer currently supports macOS and Linux.
This script deliberately does not fall through to the upstream installer or
modify any AI-client configuration. The engine remains portable to Windows,
but Tender's Windows install path has not yet passed its release gate.
"@
