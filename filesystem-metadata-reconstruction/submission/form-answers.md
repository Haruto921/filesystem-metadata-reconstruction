# Submission Form Answers

## Task Information

**Task Name:** filesystem-metadata-reconstruction  
**Version:** 1.0.0  
**Difficulty:** Hard  
**Primary Language:** Haskell (tooling), Bash (scripts)

## Implementation Summary

### Repository Architecture
Standard Terminus Edition 2 layout with clear separation between environment, solution, and tests.

### Environment Architecture
- Ubuntu 22.04 base image
- Non-root user execution
- Offline dependencies (jq, coreutils, python3)
- Deterministic workspace initialization

### Metadata Design
- JSON catalog with object records (id, path, type, checksum, size, parent_id)
- Secondary indexes (id_index, checksum_index, type_index, path_index)
- Directory manifests listing children
- Intentional corruption: duplicate IDs, invalid references, wrong checksums, stale indexes

### Docker Architecture
- Single-stage build from ubuntu:22.04
- Pinned dependency versions
- Seed data copied during build
- Non-privileged runtime user

### Oracle Strategy
Six-phase reconstruction:
1. Scan archive contents deterministically
2. Build complete catalog with correct checksums
3. Regenerate all indexes from catalog
4. Regenerate manifests from hierarchy
5. Generate reconstruction report
6. Validate using provided tools

### Testing Strategy
- Visible tests: Output existence, schema validation, tool execution
- Hidden tests: Uniqueness, completeness, referential integrity, checksum verification, acyclic hierarchy, size accuracy, index consistency, manifest accuracy

### CI Validation Strategy
- Docker build verification
- Oracle execution and output validation
- Visible and hidden test execution
- Determinism check via repeated runs

### Hidden Test Strategy
Tests verify correctness properties without revealing expected values:
- Every archive file represented exactly once
- All IDs globally unique
- Parent references resolve correctly
- Hierarchy is acyclic
- Checksums match actual content
- File sizes match actual sizes
- Indexes consistent with catalog
- Manifests accurately reflect contents

### Failure Injection Strategy
Corruption patterns in seed data:
- Duplicate object IDs
- Invalid parent references
- Incorrect checksums
- Wrong file sizes
- Stale/outdated indexes
- Missing object records

## Verification Results

### Docker Build
- Base image: ubuntu:22.04
- Dependencies installed successfully
- Seed data populated correctly
- Non-root user configured

### Oracle Execution
- Completes in deterministic time
- Produces valid catalog.json
- Generates all required indexes
- Creates accurate manifests
- Produces reconstruction report
- Passes all validation tools

### Test Results
- Visible tests pass after oracle execution
- Hidden tests verify deep correctness
- Archive integrity preserved

### Determinism
- Sorted traversal ensures consistent ordering
- No timestamps in outputs
- Reproducible across runs
