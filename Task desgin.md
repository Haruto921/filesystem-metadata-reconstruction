Filesystem Metadata Reconstruction
Implementation Specification for AI Coding Agent
Target Platform: Snorkel AI Terminus Edition 2 (Terminal-Bench Style)
Document Purpose

This document defines the implementation requirements for constructing the Filesystem Metadata Reconstruction benchmark task.

It is intended for an AI coding agent responsible for implementing the benchmark. The implementation must follow the Terminus Edition 2 architecture and remain fully deterministic, self-contained, and reproducible.

This specification intentionally describes what must be implemented rather than prescribing implementation details.

1. Repository Structure

The repository shall follow the standard Terminus task layout.

filesystem-metadata-reconstruction/
│
├── instruction.md
├── task.toml
│
├── environment/
│ ├── Dockerfile
│ ├── docker-compose.yaml
│ ├── bootstrap.sh
│ └── seed/
│ ├── archive/
│ ├── metadata/
│ ├── tools/
│ └── fixtures/
│
├── solution/
│ └── solve.sh
│
├── tests/
│ ├── test.sh
│ ├── test_outputs.py
│ ├── hidden/
│ └── fixtures/
│
└── README_INTERNAL.md

Implementation shall preserve complete separation between:

runtime environment
oracle
evaluation
benchmark description

The runtime image must never contain oracle or test assets.

2. Docker Environment Requirements
   Operating System

The environment should use a stable Ubuntu LTS release suitable for reproducible execution.

Container Design

Requirements:

single container
deterministic startup
offline execution
reproducible builds
non-privileged execution
fixed dependency versions

No runtime network connectivity should be required.

Dockerfile Responsibilities

The Dockerfile shall:

install all runtime dependencies
create workspace layout
populate the initial benchmark environment
configure execution user
initialize corrupted dataset
install validation utilities
configure PATH if required

The Dockerfile shall not:

include oracle implementation
include tests
include benchmark solution
install test-only dependencies
Runtime Directory Layout

The container should expose a working directory similar to:

/workspace
│
├── archive/
├── metadata/
├── reports/
├── tools/
├── logs/
└── tmp/

The archive directory represents immutable production data.

Only metadata and report outputs should require modification.

3. Environment Setup Requirements

Environment initialization shall create a realistic production repository before the benchmark begins.

Initialization should include:

Archive Dataset

Populate the archive with multiple categories of files, such as:

documents
media
datasets
images

The dataset should contain sufficient diversity to require meaningful inspection.

Metadata Repository

Create intentionally corrupted metadata including:

incomplete catalog
inconsistent indexes
duplicate identifiers
invalid references
stale derived data

The corruption should appear realistic rather than synthetic.

Validation Utilities

Provide utilities that support investigation without revealing solutions.

Possible utilities include:

metadata validator
repository inspector
schema validator
consistency checker

Utilities should report failures but should not explain how to repair them.

Documentation

Provide operational documentation describing:

metadata schema
directory conventions
integrity rules
expected system behavior

Documentation should define requirements but not reconstruction procedures.

4. Required Source Files

The implementation should provide the following functional components.

Metadata Catalog

Primary metadata representation.

Responsibilities:

object records
identifiers
hierarchy
references
checksums
timestamps
Manifest System

Derived metadata representing archive contents.

Responsibilities:

directory manifests
file membership
aggregate metadata
Secondary Indexes

Indexes generated from the catalog.

Examples:

identifier index
checksum index
type index
path lookup

Indexes should be derived rather than authoritative.

Validation Framework

Responsible for verifying metadata integrity.

Validation should include:

schema correctness
uniqueness
referential integrity
checksum verification
hierarchy validation
index consistency

Validation failures should be descriptive enough to aid debugging but should not disclose hidden evaluation rules.

Reporting

The benchmark should generate a reconstruction report summarizing the repaired state.

The report format should be deterministic and machine-readable.

5. Oracle Implementation Requirements

The oracle represents the canonical engineering solution.

Its purpose is to demonstrate that the task is solvable rather than to expose the answer.

Oracle Workflow

The oracle should perform an investigative workflow that resembles an experienced systems engineer.

Expected phases include:

Inspect repository state.
Analyze metadata schema.
Identify inconsistencies.
Enumerate archive contents.
Reconstruct missing records.
Recompute derived metadata.
Rebuild indexes.
Validate reconstructed state.
Produce final report.

The oracle should avoid assumptions that bypass analysis.

Oracle Output

The oracle should leave the repository in a fully consistent state while preserving the archived data.

Expected outputs include:

reconstructed catalog
regenerated indexes
regenerated manifests
reconstruction report
Oracle Constraints

The oracle must not:

modify archived payload files
disable validators
alter evaluation utilities
rely on hidden test artifacts
use hardcoded benchmark outputs

The oracle should remain deterministic across repeated executions.

6. Test Implementation Requirements

The evaluation system should distinguish between superficial repairs and complete reconstruction.

Visible Tests

Visible tests should verify foundational requirements, including:

required outputs exist
metadata conforms to schema
validation utility reports success
reconstruction report is present

These tests should communicate expected deliverables without revealing all correctness conditions.

Hidden Tests

Hidden tests should verify deeper properties such as:

every archive object is represented exactly once
identifiers are globally unique
references resolve correctly
hierarchy is acyclic
checksums match archived content
manifests accurately reflect archive contents
indexes are regenerated from reconstructed metadata
timestamps satisfy documented invariants
derived statistics are internally consistent

Hidden tests should focus on correctness of the reconstructed system rather than matching specific implementation choices.

Integrity Protection

Evaluation should verify that protected resources remain unchanged.

Examples include:

archive payloads
validation utilities
benchmark tooling

Integrity mechanisms may include cryptographic hashes or equivalent deterministic checks.

Anti-Cheating Requirements

Tests should detect attempts to:

replace validators
modify benchmark tooling
fabricate expected outputs
bypass reconstruction by disabling verification
infer solutions from evaluation artifacts 7. Continuous Integration Validation

The implementation should support deterministic automated validation.

Build Validation

CI should verify that:

Docker image builds successfully
environment initializes correctly
workspace layout matches specification
required assets are present
Oracle Validation

CI should execute the oracle and confirm that:

reconstruction completes successfully
validation passes
expected outputs are generated
archived data remains unchanged
Test Validation

CI should execute both visible and hidden evaluations to confirm:

deterministic behavior
complete reconstruction
absence of unauthorized modifications
integrity of derived metadata
Repeatability

Multiple independent executions should produce equivalent validated outcomes.

The benchmark should avoid nondeterministic behavior arising from:

timestamps not controlled by the task
random ordering
unstable filesystem traversal
environment-dependent behavior
Repository Validation

CI should additionally verify compliance with the Terminus task format, including:

required repository structure
isolation of environment, oracle, and tests
absence of oracle and test assets from the runtime image
pinned runtime dependencies
non-privileged container configuration
valid task metadata
deterministic evaluation scripts
Implementation Constraints

The implementation should satisfy the following architectural constraints:

Self-contained: All resources required for execution must be packaged within the benchmark.
Offline: No network access or external services should be required.
Deterministic: Repeated executions under identical conditions should yield the same validated outcome.
Outcome-oriented: Evaluation should assess the correctness of the reconstructed system state rather than the specific sequence of commands used.
Realistic: The repository, metadata, corruption patterns, and tooling should resemble a plausible production engineering environment.
Generalization-resistant: Visible artifacts should not reveal the complete solution; hidden tests should ensure that only a genuinely reconstructed metadata system passes evaluation.

Additional Project Constraints
Difficulty: Hard

Primary Language:

- Haskell

Deliverables:

- instruction.md
- task.toml
- environment/
- solution/
- tests/
- submission/form-answers.md

Implementation Requirements

This project targets the Snorkel AI Terminus Edition 2 benchmark.

The implementation MUST follow the official Terminal-Bench task architecture and the engineering specification previously studied by the AI agent.

Before writing any implementation code:

1. Build a complete implementation plan based on the Task Author Requirement Specification and the provided engineering specification.

2. The implementation plan must include:
   - repository architecture
   - environment architecture
   - metadata design
   - Docker architecture
   - oracle strategy
   - testing strategy
   - CI validation strategy
   - hidden test strategy
   - failure injection strategy

3. Do NOT begin implementation immediately.

4. Present the implementation plan first.

5. Wait for user review and approval before writing any files.

6. The implementation must include:
   - instruction.md
   - task.toml
   - environment/
   - solution/
   - tests/
   - submission/form-answers.md

7. Do not skip Oracle (golden solution) verification.

8. Do not skip NOP verification.

9. Do not skip deterministic test verification.

10. Build every component according to the official Snorkel Terminus Edition 2 engineering requirements previously studied.

The implementation should prioritize benchmark quality over implementation speed.
