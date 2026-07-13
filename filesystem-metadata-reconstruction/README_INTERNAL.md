# Filesystem Metadata Reconstruction - Internal README

## Overview

This benchmark task requires reconstructing a corrupted filesystem metadata repository. The archive contains immutable production data, but the metadata catalog has become inconsistent.

## Quick Start

### Build Docker Image

```bash
cd environment
docker build -t filesystem-metadata-reconstruction:latest .
```

### Run Oracle Solution

```bash
docker run --rm filesystem-metadata-reconstruction:latest /oracle/solve.sh
```

### Run Tests

```bash
# Visible tests
docker run --rm filesystem-metadata-reconstruction:latest /tests/test.sh
docker run --rm filesystem-metadata-reconstruction:latest python3 /tests/test_outputs.py

# Hidden tests
docker run --rm filesystem-metadata-reconstruction:latest python3 /tests/hidden/test_hidden.py
```

## Directory Structure

```
filesystem-metadata-reconstruction/
├── instruction.md          # User-facing instructions
├── task.toml              # Task metadata
├── README_INTERNAL.md     # This file
│
├── environment/
│   ├── Dockerfile         # Runtime environment
│   ├── docker-compose.yaml
│   └── seed/
│       ├── archive/       # Immutable production files
│       ├── metadata/      # Corrupted metadata (initial state)
│       └── tools/         # Validation utilities
│
├── solution/
│   └── solve.sh           # Oracle solution
│
├── tests/
│   ├── test.sh            # Visible shell tests
│   ├── test_outputs.py    # Visible Python tests
│   └── hidden/
│       └── test_hidden.py # Hidden correctness tests
│
└── submission/
    └── form-answers.md    # Submission documentation
```

## Corruption Patterns

The seed metadata contains these intentional corruptions:

1. **Duplicate IDs**: Same ID used for different objects
2. **Invalid References**: parent_id points to non-existent object
3. **Wrong Checksums**: checksum doesn't match actual file content
4. **Incorrect Sizes**: size field doesn't match actual file size
5. **Missing Records**: Some archive files not represented in catalog
6. **Stale Indexes**: Derived data doesn't match catalog

## Expected Solution Behavior

The oracle solution must:

1. Scan the archive directory to discover all files and directories
2. Generate unique IDs for each object
3. Compute correct SHA256 checksums for all files
4. Record accurate file sizes
5. Build correct parent-child relationships
6. Regenerate all secondary indexes
7. Regenerate all directory manifests
8. Produce a reconstruction report
9. Pass all validation checks

## Validation Rules

### Schema Validation
- catalog.json must be valid JSON with "objects" array
- Each object must have: id, path, type, checksum, size, parent_id

### Integrity Validation
- All IDs must be unique
- All parent_id references must resolve to existing objects
- Hierarchy must be acyclic

### Checksum Validation
- File checksums must match SHA256 of actual content
- File sizes must match actual file sizes

### Completeness Validation
- Every archive file must be represented exactly once
- All directories must be represented

## Determinism Guarantees

The implementation ensures determinism through:

- Sorted directory/file traversal
- Sequential ID assignment
- No timestamps in outputs
- No random ordering
- Consistent JSON formatting via jq

## Anti-Cheating Measures

1. Validation tools cannot be modified or replaced
2. Archive files are read-only
3. Hidden tests verify deep correctness properties
4. Tests check for tampering with validators
5. Checksums prevent fabrication of outputs

## Troubleshooting

### Common Issues

1. **jq not found**: Ensure Docker image builds correctly
2. **Permission denied**: Verify non-root user setup
3. **Validation fails**: Check that all corruption is properly fixed
4. **Non-deterministic output**: Ensure sorted traversal

### Debugging Tips

Run validation tools individually to identify specific failures:
```bash
/workspace/tools/validate-schema.sh
/workspace/tools/check-integrity.sh
/workspace/tools/verify-checksums.sh
```

## License

Internal benchmark use only.
