# Filesystem Metadata Reconstruction

## Overview

You are tasked with reconstructing a corrupted filesystem metadata repository. The archive contains immutable production data, but the metadata catalog has become inconsistent due to system failures.

## Your Environment

The workspace contains:

- `/workspace/archive/` - Immutable production files (DO NOT MODIFY)
- `/workspace/metadata/` - Corrupted metadata repository (REPAIR THIS)
- `/workspace/tools/` - Validation utilities
- `/workspace/reports/` - Output directory for reconstruction report
- `/workspace/logs/` - Log output directory
- `/workspace/tmp/` - Temporary working space

## Problem

The metadata catalog has suffered corruption including:
- Missing object records
- Duplicate identifiers
- Invalid references
- Checksum mismatches
- Stale derived data (indexes and manifests)

## Requirements

1. **Inspect** the current metadata state using validation tools
2. **Analyze** the archive contents to understand what should be represented
3. **Reconstruct** the metadata catalog to accurately reflect the archive
4. **Regenerate** all derived metadata (indexes, manifests)
5. **Validate** the reconstructed state passes all checks
6. **Report** the reconstruction results

## Deliverables

After reconstruction, the following must exist:

1. `/workspace/metadata/catalog.json` - Complete and consistent object catalog
2. `/workspace/metadata/manifests/` - Directory manifests reflecting archive contents
3. `/workspace/metadata/indexes/` - Regenerated secondary indexes
4. `/workspace/reports/reconstruction.json` - Reconstruction summary report

## Validation

Use the provided tools to validate your work:

```bash
# Check metadata schema
/workspace/tools/validate-schema.sh

# Check referential integrity
/workspace/tools/check-integrity.sh

# Verify checksums
/workspace/tools/verify-checksums.sh

# Full validation
/workspace/tools/full-validation.sh
```

## Constraints

- Do NOT modify files in `/workspace/archive/`
- Do NOT modify validation tools in `/workspace/tools/`
- All outputs must be deterministic (no timestamps, random ordering, etc.)
- Work offline - no network access available

## Metadata Schema

### Catalog (catalog.json)

```json
{
  "objects": [
    {
      "id": "<unique-identifier>",
      "path": "<relative-path-in-archive>",
      "type": "file|directory",
      "checksum": "<sha256-hash>",
      "size": <bytes>,
      "parent_id": "<parent-directory-id-or-null>"
    }
  ]
}
```

### Indexes

- `id_index.json` - Map of ID to object record
- `checksum_index.json` - Map of checksum to IDs
- `type_index.json` - Map of type to ID list
- `path_index.json` - Map of path to ID

### Manifests

Each directory has a manifest file listing its direct children.

## Success Criteria

Your reconstruction passes when:
1. All validation tools report success
2. Every archive file is represented exactly once in the catalog
3. All identifiers are unique and valid
4. All parent references resolve correctly
5. All checksums match actual file content
6. Hierarchy is acyclic and complete
7. Derived data (indexes, manifests) matches reconstructed catalog
