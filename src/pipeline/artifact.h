/*
 * artifact.h — Persistent artifact export/import for team sharing.
 *
 * Exports the SQLite knowledge graph as a zstd-compressed artifact
 * to .codebase-memory/graph.db.zst in the repository. Teammates
 * can import the artifact to bootstrap their local index instead
 * of running a full pipeline from scratch.
 */
#ifndef CBM_ARTIFACT_H
#define CBM_ARTIFACT_H

#include <stdbool.h>

/* Schema version — increment when DB schema changes (new tables/indexes).
 * Import refuses artifacts with schema_version > current.
 * v2: edges uniqueness widened to (source_id, target_id, type,
 *     local_name_gen) so sibling named imports coexist (#768) — old
 *     binaries cannot upsert against the widened constraint. */
#define CBM_ARTIFACT_SCHEMA_VERSION 2

#define CBM_ARTIFACT_FILENAME "graph.db.zst"
#define CBM_ARTIFACT_META "artifact.json"
#define CBM_ARTIFACT_DIR ".codebase-memory"

/* Export quality levels */
enum {
    CBM_ARTIFACT_FAST = 0, /* zstd -3, no index stripping (watcher path) */
    CBM_ARTIFACT_BEST = 1, /* zstd -9 + drop indexes + VACUUM INTO (explicit index) */
};

/* Export DB to .codebase-memory/graph.db.zst artifact.
 * quality: CBM_ARTIFACT_FAST or CBM_ARTIFACT_BEST.
 * Creates .codebase-memory/ dir, .gitattributes, and artifact.json.
 * Returns 0 on success, -1 on error. */
int cbm_artifact_export(const char *db_path, const char *repo_path, const char *project_name,
                        int quality);

/* Export to artifact_root/.codebase-memory/ instead of modifying the source
 * repository. source_repo_path is used only for commit identity; no files are
 * written there and no git attributes are changed. This is the project-index
 * seam used by CI/registry workflows. */
int cbm_artifact_export_to(const char *db_path, const char *source_repo_path,
                           const char *artifact_root, const char *project_name, int quality);

/* Get details for the most recent export failure on this thread.
 * Returns NULL if no export error is recorded. */
const char *cbm_artifact_export_last_error(void);

/* Import artifact from .codebase-memory/graph.db.zst to cache_db_path.
 * Decompresses, runs integrity check, recreates indexes.
 * Returns 0 on success, -1 on error. */
int cbm_artifact_import(const char *repo_path, const char *cache_db_path);

/* Import a detached project artifact only when a valid payload digest is
 * present and matches. This combines verification and import so callers do
 * not create a verify/use race. */
int cbm_artifact_import_verified(const char *artifact_root, const char *cache_db_path);

/* Verify the compressed payload against artifact.json. When require_digest is
 * true, legacy artifacts without artifact_sha256 are rejected. */
bool cbm_artifact_verify(const char *artifact_root, bool require_digest);

/* Return true only when the artifact's recorded source commit is an ancestor
 * of the repository's current HEAD. Both the commit and repository path are
 * validated before invoking git. */
bool cbm_artifact_commit_is_ancestor(const char *artifact_root, const char *repo_path);

/* Check if a compatible artifact exists in repo_path/.codebase-memory/.
 * Returns true only if both graph.db.zst and artifact.json exist
 * and schema_version is compatible. */
bool cbm_artifact_exists(const char *repo_path);

/* Get the git commit hash from artifact metadata. Caller must free().
 * Returns NULL if artifact doesn't exist or has no commit field. */
char *cbm_artifact_commit(const char *repo_path);

/* Whether repo_path is safe to interpolate into a double-quoted `git -C "…"` shell
 * command (as artifact.c does via cbm_popen). Rejects quote / backslash / shell
 * substitution metacharacters (cbm_validate_shell_arg); on Windows also rejects the
 * cmd.exe expansion metacharacters % ! ^. Spaces ARE allowed — double quotes handle
 * them on both POSIX sh and cmd.exe (single quotes, which cmd.exe does not honor,
 * were the pre-existing bug). Exposed so the shell-safety contract is unit-tested. */
bool cbm_artifact_repo_path_is_shell_safe(const char *repo_path);

#endif /* CBM_ARTIFACT_H */
