# Filesystem Metadata Reconstruction

## Task Description

You are tasked with reconstructing filesystem metadata from corrupted archive files. The archives contain JSON metadata describing file hierarchies, but some entries may be corrupted with invalid data such as:
- Empty filenames
- Negative file sizes
- Missing required fields
- Invalid type specifications

## Your Goal

1. Parse all metadata JSON files in `data/metadata/`
2. Validate each entry against the schema
3. Detect and report corruption patterns
4. Reconstruct a valid filesystem hierarchy from clean entries
5. Generate a reconstruction report

## Available Tools

- `jq` - JSON processing
- Standard Unix tools (bash, grep, sed, awk)
- Haskell oracle solution in `solution/`

## Data Format

Each metadata file contains an array of entries with the following schema:

```json
{
  "name": "path/to/file",
  "size": 1234,
  "type": "file|directory|symlink",
  "checksum": "abc123" or null
}
```

## Validation Rules

1. **Name**: Must be a non-empty string
2. **Size**: Must be a non-negative integer
3. **Type**: Must be one of: "file", "directory", "symlink"
4. **Checksum**: Optional, can be null or a string

## Expected Output

Create a file `output/reconstruction_report.json` with the following structure:

```json
{
  "processed_files": ["archive-001.json", ...],
  "total_entries": 100,
  "valid_entries": 95,
  "corrupted_entries": 5,
  "corruption_details": [
    {
      "file": "corrupted-001.json",
      "entry_index": 0,
      "error": "Empty filename"
    }
  ],
  "reconstructed_hierarchy": {
    "directories": [...],
    "files": [...]
  }
}
```

## Hints

- Use `jq` to parse and validate JSON
- Check for empty names with `.[] | select(.name == "")`
- Check for negative sizes with `.[] | select(.size < 0)`
- Directory entries should have size 0

## Testing

Run visible tests to verify your understanding:
```bash
./tests/visible/run_visible_tests.sh
```
