#!/usr/bin/env bash
# Tender Project — build and consume commit-addressed project-index artifacts.
#
# This wrapper intentionally never runs the upstream install command and never
# edits Claude, Codex, Cursor, or other agent configuration. It only invokes the
# local one-shot index tool against a repository chosen by the caller.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
    printf '%s\n' \
        'Usage:' \
        '  scripts/tender-project.sh build  --repo PATH --output PATH [--project NAME] [--binary PATH] [--mode MODE]' \
        '  scripts/tender-project.sh verify --artifact-root PATH [--repo PATH]' \
        '  scripts/tender-project.sh load   --repo PATH --artifact-root PATH [--binary PATH] [--mode MODE] [--cache-dir PATH]' \
        '' \
        'Commands:' \
        '  build   Index a clean Git commit into a detached artifact root.' \
        '  verify  Check payload digest and, when --repo is given, source ancestry.' \
        '  load    Verify, import, and incrementally overlay the selected local checkout.' \
        '' \
        'Nothing here modifies agent configuration or publishes an artifact.'
}

die() {
    printf 'tender-project: %s\n' "$*" >&2
    exit 1
}

absolute_dir() {
    local path="$1"
    mkdir -p "$path"
    (cd "$path" && pwd -P)
}

repo_root() {
    git -C "$1" rev-parse --show-toplevel 2>/dev/null ||
        die "not a Git repository: $1"
}

find_binary() {
    local requested="${1:-}"
    if [[ -n "$requested" ]]; then
        [[ -x "$requested" ]] || die "binary is not executable: $requested"
        printf '%s\n' "$requested"
        return
    fi
    local candidate
    for candidate in \
        "$ROOT/build/c/codebase-memory-mcp" \
        "$ROOT/build/tender-project/codebase-memory-mcp" \
        "$ROOT/build/baseline/codebase-memory-mcp"; do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
    die "build the engine first with scripts/build.sh, or pass --binary"
}

json_string_field() {
    local file="$1"
    local field="$2"
    sed -nE "s/^[[:space:]]*\"${field}\"[[:space:]]*:[[:space:]]*\"([^\"]+)\"[,]?[[:space:]]*$/\\1/p" "$file" |
        head -n 1
}

sha256_file() {
    local file="$1"
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    elif command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 "$file" | awk '{print $NF}'
    else
        die 'no SHA-256 implementation found (shasum, sha256sum, or openssl)'
    fi
}

cleanup_temp_cache() {
    local temp_parent
    [[ -n "${temp_cache:-}" ]] || return
    temp_parent="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
    case "$temp_cache" in
        "$temp_parent"/tender-project-cache.*)
            [[ -d "$temp_cache" ]] && find "$temp_cache" -depth -delete
            ;;
    esac
}

artifact_paths() {
    local root="$1"
    ARTIFACT_DIR="$root/.codebase-memory"
    ARTIFACT_DB="$ARTIFACT_DIR/graph.db.zst"
    ARTIFACT_META="$ARTIFACT_DIR/artifact.json"
    [[ -f "$ARTIFACT_DB" ]] || die "missing $ARTIFACT_DB"
    [[ -f "$ARTIFACT_META" ]] || die "missing $ARTIFACT_META"
}

verify_artifact() {
    local root="$1"
    local repo="${2:-}"
    artifact_paths "$root"
    local expected actual commit
    expected="$(json_string_field "$ARTIFACT_META" artifact_sha256)"
    [[ "$expected" =~ ^[0-9a-f]{64}$ ]] || die 'artifact metadata has no valid SHA-256 digest'
    actual="$(sha256_file "$ARTIFACT_DB")"
    [[ "$actual" == "$expected" ]] || die 'artifact payload digest does not match metadata'
    commit="$(json_string_field "$ARTIFACT_META" commit)"
    [[ "$commit" =~ ^[0-9a-fA-F]{7,64}$ ]] || die 'artifact metadata has no valid source commit'
    if [[ -n "$repo" ]]; then
        repo="$(repo_root "$repo")"
        git -C "$repo" merge-base --is-ancestor "$commit" HEAD 2>/dev/null ||
            die "artifact commit $commit is not an ancestor of $(git -C "$repo" rev-parse HEAD)"
    fi
    printf 'verified artifact commit=%s sha256=%s\n' "$commit" "$actual"
}

command="${1:-}"
[[ -n "$command" ]] || { usage; exit 2; }
case "$command" in
    -h|--help) usage; exit 0 ;;
esac
shift

repo=""
output=""
artifact_root=""
project=""
binary=""
cache_dir=""
mode="full"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo) repo="${2:-}"; shift 2 ;;
        --repo=*) repo="${1#*=}"; shift ;;
        --output) output="${2:-}"; shift 2 ;;
        --output=*) output="${1#*=}"; shift ;;
        --project) project="${2:-}"; shift 2 ;;
        --project=*) project="${1#*=}"; shift ;;
        --artifact-root) artifact_root="${2:-}"; shift 2 ;;
        --artifact-root=*) artifact_root="${1#*=}"; shift ;;
        --binary) binary="${2:-}"; shift 2 ;;
        --binary=*) binary="${1#*=}"; shift ;;
        --cache-dir) cache_dir="${2:-}"; shift 2 ;;
        --cache-dir=*) cache_dir="${1#*=}"; shift ;;
        --mode) mode="${2:-}"; shift 2 ;;
        --mode=*) mode="${1#*=}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
done

case "$mode" in
    full|moderate|fast) ;;
    *) die "unsupported mode: $mode" ;;
esac

case "$command" in
    build)
        [[ -n "$repo" ]] || die 'build requires --repo'
        [[ -n "$output" ]] || die 'build requires --output'
        repo="$(repo_root "$repo")"
        [[ -z "$(git -C "$repo" status --porcelain --untracked-files=normal)" ]] ||
            die 'refusing to publish an artifact for a dirty working tree'
        output="$(absolute_dir "$output")"
        case "$output/" in
            "$repo/"*) die 'artifact output must be outside the source repository' ;;
        esac
        if [[ -n "$(find "$output" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
            die "artifact output is not empty: $output"
        fi
        binary="$(find_binary "$binary")"
        if [[ -z "$project" ]]; then
            project="$(basename "$repo")"
        fi
        temp_parent="$(cd "${TMPDIR:-/tmp}" && pwd -P)"
        temp_cache="$(mktemp -d "$temp_parent/tender-project-cache.XXXXXX")"
        trap cleanup_temp_cache EXIT
        CBM_CACHE_DIR="$temp_cache/cache" "$binary" cli index_repository \
            --repo-path "$repo" --name "$project" --mode "$mode" --persistence \
            --artifact-output "$output"
        verify_artifact "$output" "$repo"
        printf 'project artifact: %s/.codebase-memory\n' "$output"
        ;;
    verify)
        [[ -n "$artifact_root" ]] || die 'verify requires --artifact-root'
        artifact_root="$(absolute_dir "$artifact_root")"
        verify_artifact "$artifact_root" "$repo"
        ;;
    load)
        [[ -n "$repo" ]] || die 'load requires --repo'
        [[ -n "$artifact_root" ]] || die 'load requires --artifact-root'
        repo="$(repo_root "$repo")"
        artifact_root="$(absolute_dir "$artifact_root")"
        verify_artifact "$artifact_root" "$repo"
        binary="$(find_binary "$binary")"
        project="$(json_string_field "$artifact_root/.codebase-memory/artifact.json" project)"
        [[ -n "$project" ]] || die 'artifact metadata has no project identity'
        if [[ -n "$cache_dir" ]]; then
            cache_dir="$(absolute_dir "$cache_dir")"
            CBM_CACHE_DIR="$cache_dir" "$binary" cli index_repository \
                --repo-path "$repo" --name "$project" --mode "$mode" \
                --artifact-input "$artifact_root"
        else
            "$binary" cli index_repository --repo-path "$repo" --name "$project" \
                --mode "$mode" --artifact-input "$artifact_root"
        fi
        ;;
    *)
        usage
        die "unknown command: $command"
        ;;
esac
