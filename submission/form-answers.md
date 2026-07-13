# Filesystem Metadata Reconstruction - Form Answers

## Task Information

| Field | Value |
|-------|-------|
| Task Name | filesystem-metadata-reconstruction |
| Version | 1.0.0 |
| Difficulty | Hard |
| Primary Language | Haskell |
| Execution Environment | Docker (haskell:9.4.8) |

## Implementation Details

### Oracle Solution
- **Location**: `solution/Main.hs`
- **Description**: Haskell program that parses metadata JSON files, validates entries against schema rules, detects corruption patterns, and reconstructs filesystem hierarchy
- **Key Functions**:
  - `parseArchiveMetadata`: Parse JSON metadata
  - `validateMetadata`: Validate entries against schema
  - `reconstructFilesystem`: Build filesystem map from valid entries

### Test Suite

#### Visible Tests (`tests/visible/run_visible_tests.sh`)
- Basic file existence checks
- JSON structure validation
- Schema field presence verification
- Entry count validation
- Type validation (file/directory)
- Corruption pattern detection

#### Hidden Tests (`tests/hidden/run_hidden_tests.sh`)
- Oracle processing verification
- Path uniqueness integrity
- Hierarchy consistency validation
- Size aggregation calculations
- Corruption detection accuracy
- Determinism verification
- Edge case handling

### Data Files
- `data/metadata/archive-001.json`: Valid archive with 6 entries
- `data/metadata/archive-002.json`: Valid archive with 5 entries  
- `data/metadata/corrupted-001.json`: Corrupted archive with validation errors

### Docker Environment
- **Base Image**: haskell:9.4.8
- **Additional Tools**: jq, zip, unzip
- **Build Process**: cabal build of Haskell solution
- **Determinism**: C.UTF-8 locale set for consistent behavior

## Validation Results

### Docker Build
- Status: Ready to build
- Command: `docker build -f environment/Dockerfile -t filesystem-reconstruction .`

### Oracle Verification
- Parses all metadata files
- Validates schema compliance
- Detects empty names and negative sizes
- Reconstructs filesystem hierarchy

### NOP Verification
- Empty input handling: Outputs "No metadata files found" when data/metadata is empty
- Graceful error handling for malformed JSON

### Determinism Verification
- Same input produces identical output across runs
- JSON processing uses deterministic sorting
- No random or time-dependent operations

## Anti-Cheating Measures

1. **Hidden Tests**: Evaluation includes tests not visible to agents
2. **Multiple Validation Layers**: Schema, integrity, and hierarchy checks
3. **Determinism Requirement**: Non-deterministic solutions fail evaluation
4. **Offline Execution**: No network access allowed

## Known Limitations

1. The oracle currently processes files sequentially; parallel processing could improve performance for large datasets
2. Checksum validation is not implemented (checksums are stored but not verified against actual content)
3. Symlink target resolution is not implemented

## Future Enhancements

1. Add checksum verification against actual file content
2. Implement parallel processing for large archives
3. Add support for additional corruption patterns (invalid types, missing fields)
4. Generate visual filesystem tree representation
