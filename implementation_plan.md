# Implementation Plan: Broken Python Build System Recovery with Dependency Lock Repair

## 1. Repository Structure Design

```
/workspace/
├── task/
│   ├── instruction.md          # User-facing task description (problem statement only)
│   └── task.toml               # Task metadata (difficulty, category, etc.)
├── environment/
│   ├── Dockerfile              # Base environment setup for the task
│   └── docker-compose.yml      # Optional: for local testing
├── tests/
│   ├── test_docker_build.py    # Public test: verifies docker build succeeds
│   ├── test_installation.py    # Public test: verifies pip install . works
│   ├── test_pytest_suite.py    # Public test: verifies existing tests pass
│   └── hidden/
│       ├── test_clean_install.py      # Hidden: clean environment installation
│       ├── test_dependency_stability.py # Hidden: version constraints check
│       ├── test_regression.py         # Hidden: functional regression tests
│       └── test_docker_reproducibility.py # Hidden: reproducible builds
├── solution/
│   ├── solve.sh                # Oracle solution script (applies minimal fixes)
│   └── patches/
│       ├── pyproject.toml.patch
│       ├── requirements.txt.patch
│       ├── Dockerfile.patch
│       └── ci.yml.patch
├── submission/
│   └── validate.sh             # Validation script for final verification
└── project/                    # The broken repository (initial state for agent)
    ├── pyproject.toml          # BROKEN: invalid packaging config
    ├── requirements.txt        # BROKEN: conflicting dependencies
    ├── requirements-dev.txt    # BROKEN: dev dependency conflicts
    ├── Dockerfile              # BROKEN: build errors
    ├── Makefile
    ├── src/
    │   └── application/
    │       ├── __init__.py
    │       ├── main.py
    │       ├── config.py
    │       └── utils.py
    ├── tests/
    │   ├── __init__.py
    │   ├── test_core.py
    │   └── test_config.py
    ├── scripts/
    │   └── build.sh
    └── .github/
        └── workflows/
            └── ci.yml          # BROKEN: CI configuration drift
```

---

## 2. Docker Design

### Base Image
- **Image**: `ubuntu:22.04`
- **Rationale**: Specified in task spec, stable LTS release

### System Dependencies
```dockerfile
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    python3-venv \
    git \
    gcc \
    make \
    curl \
    grep \
    sed \
    find \
    tree \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
```

### Python Environment Setup
```dockerfile
# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install Python tools
RUN pip3 install --upgrade pip \
    && pip3 install pytest build pip-tools setuptools wheel
```

### Versions
- Python: 3.11.x (from Ubuntu 22.04 repos or deadsnakes PPA)
- pip: latest compatible
- pytest: 7.x or 8.x
- Docker: Host Docker used for building

---

## 3. Test Architecture

### 3.1 Correctness Tests (Public)

#### Test 1: Docker Build (`test_docker_build.py`)
- **Purpose**: Verify `docker build .` succeeds from project root
- **Execution**: Run `docker build -t test-project .` inside project directory
- **Validation**:
  - Exit code == 0
  - Image is created and inspectable
  - No resolver errors in output
- **Failure Conditions**: Any build error, non-zero exit code

#### Test 2: Package Installation (`test_installation.py`)
- **Purpose**: Verify `pip install .` works in clean venv
- **Execution**:
  ```bash
  python -m venv /tmp/test_venv
  source /tmp/test_venv/bin/activate
  cd /workspace/project && pip install .
  ```
- **Validation**:
  - Exit code == 0
  - Package metadata is valid
  - All dependencies resolve without conflict
- **Failure Conditions**: Installation error, missing metadata, dependency conflict

#### Test 3: Existing Tests Suite (`test_pytest_suite.py`)
- **Purpose**: Verify all visible tests pass
- **Execution**: `cd /workspace/project && pytest tests/ -v`
- **Validation**:
  - Exit code == 0
  - All tests pass (no failures, no errors)
- **Failure Conditions**: Any test failure

### 3.2 Edge Cases

#### Edge Case 1: Clean Environment Dependency
- Tests run in fresh virtual environment
- No reliance on pre-installed packages
- Verifies all dependencies are properly declared

#### Edge Case 2: Working Directory Independence
- Tests verify package works regardless of cwd
- No hardcoded absolute paths

#### Edge Case 3: Multiple Build Attempts
- Docker build tested twice to ensure reproducibility
- No transient state dependencies

### 3.3 Failure Tests (Hidden)

#### Hidden Test 1: Clean Installation (`test_clean_install.py`)
- **Procedure**: Create entirely new Docker container, install package
- **Checks**:
  - No undeclared dependencies
  - Works outside original container context
- **Failure**: Installation only works in original container

#### Hidden Test 2: Dependency Stability (`test_dependency_stability.py`)
- **Procedure**: Run `pip freeze`, parse versions
- **Validation**: Resolved versions satisfy expected constraints
- **Checks**: urllib3 version compatibility, no uncontrolled upgrades
- **Failure**: Unstable or conflicting dependency versions

#### Hidden Test 3: Regression Validation (`test_regression.py`)
- **Procedure**: Run hidden functional tests
- **Checks**:
  - Application imports work
  - Configuration loading works
  - Main module executes correctly
  - Utils functions behave as expected
- **Failure**: Functional regression in application behavior

#### Hidden Test 4: Docker Reproducibility (`test_docker_reproducibility.py`)
- **Procedure**: Build Docker image twice consecutively
- **Validation**: Both builds succeed with same result
- **Failure**: Environment-dependent behavior, flaky builds

---

## 4. Oracle Solution Plan

### solve.sh Workflow

The oracle solution script will apply minimal, targeted fixes to restore the build system.

#### Step 1: Diagnosis Phase
```bash
# Inspect current state
cd /workspace/project
cat pyproject.toml
cat requirements.txt
cat Dockerfile
cat .github/workflows/ci.yml
```

#### Step 2: Apply Fixes

**Fix 1: requirements.txt - Resolve Dependency Conflict**
- Problem: Conflicting urllib3 constraints (package-a requires <2, package-b requires >=2)
- Solution: Pin compatible versions that satisfy all constraints
- Change: Replace conflicting packages with compatible alternatives or pin specific versions

**Fix 2: pyproject.toml - Fix Packaging Configuration**
- Problem: Invalid build-backend, outdated metadata format
- Solution: Update to modern setuptools configuration
- Changes:
  - Fix `[build-system]` section
  - Update `[project]` metadata
  - Ensure proper dependency declarations

**Fix 3: Dockerfile - Fix Build Sequence**
- Problems:
  - Wrong Python base image tag
  - Missing OS-level build dependencies
  - Incorrect WORKDIR assumptions
  - Wrong installation order
- Solution:
  - Use correct python:3.11-slim base
  - Install build-essential before pip installs
  - Set correct WORKDIR
  - Copy requirements before code for layer caching

**Fix 4: .github/workflows/ci.yml - Fix CI Drift**
- Problems:
  - Wrong Python version specified
  - Missing environment variables
  - Invalid cache configuration
- Solution:
  - Update Python version to 3.11
  - Add required env vars
  - Fix pip cache configuration

#### Step 3: Validation Phase
```bash
# Validate all fixes
docker build -t project-test .
python -m venv /tmp/validate_venv
source /tmp/validate_venv/bin/activate
pip install .
pytest tests/
```

### Expected Modified Files
1. `requirements.txt` - Compatible dependency versions
2. `pyproject.toml` - Valid packaging metadata
3. `Dockerfile` - Correct build instructions
4. `.github/workflows/ci.yml` - Updated CI configuration

---

## 5. Validation Strategy

### 5.1 Docker Build Verification
```bash
# Build the task environment
cd /workspace/environment
docker build -t terminal-bench-task .

# Verify build completes without errors
docker run --rm terminal-bench-task echo "Environment ready"
```

### 5.2 Pytest Execution
```bash
# Run public tests
cd /workspace
pytest tests/ -v

# Run hidden tests (only accessible to evaluator)
pytest tests/hidden/ -v
```

### 5.3 Oracle Execution
```bash
# Execute oracle solution
cd /workspace
bash solution/solve.sh

# Verify success criteria
echo "=== Validation ==="
cd /workspace/project && docker build . && echo "✓ Docker build"
cd /workspace/project && pip install . && echo "✓ Installation"
cd /workspace/project && pytest tests/ && echo "✓ Tests pass"
```

### 5.4 Complete Validation Script
```bash
#!/bin/bash
set -e

echo "=== Building Task Environment ==="
cd /workspace/environment
docker build -t task-env .

echo "=== Running Oracle Solution ==="
cd /workspace
bash solution/solve.sh

echo "=== Running Public Tests ==="
pytest tests/ -v --tb=short

echo "=== Running Hidden Tests ==="
pytest tests/hidden/ -v --tb=short

echo "=== All Validations Passed ==="
```

---

## 6. Risks and Mitigations

### 6.1 Schema Problems

**Risk**: pyproject.toml schema changes between setuptools versions
- **Mitigation**: Pin setuptools version in requirements-dev.txt
- **Mitigation**: Use well-documented, stable metadata format

**Risk**: Dockerfile syntax variations
- **Mitigation**: Use standard Dockerfile syntax, test on target Docker version

### 6.2 Flaky Tests

**Risk**: Network-dependent tests (pip install may fail due to network)
- **Mitigation**: Mock network calls where possible
- **Mitigation**: Use local package index for critical tests
- **Mitigation**: Add retry logic for pip operations

**Risk**: Timing-dependent tests
- **Mitigation**: Avoid time-based assertions
- **Mitigation**: Use deterministic test data

**Risk**: Order-dependent tests
- **Mitigation**: Ensure test isolation
- **Mitigation**: Each test creates its own fixtures

### 6.3 Dependency Issues

**Risk**: External package updates break tests
- **Mitigation**: Pin all dependency versions in requirements files
- **Mitigation**: Use hash-checked requirements for production deps

**Risk**: Python 3.11 compatibility issues
- **Mitigation**: Test all code on Python 3.11 specifically
- **Mitigation**: Avoid deprecated features

**Risk**: Conflicting transitive dependencies
- **Mitigation**: Carefully design initial conflict to be resolvable
- **Mitigation**: Document expected resolution path

### 6.4 Environment-Specific Issues

**Risk**: Tests pass locally but fail in CI
- **Mitigation**: Use identical Docker environment for all testing
- **Mitigation**: Avoid host-specific paths or configurations

**Risk**: Permission issues in Docker
- **Mitigation**: Run as appropriate user in Dockerfile
- **Mitigation**: Set correct file permissions

### 6.5 Task Design Risks

**Risk**: Solution is too obvious (single version change)
- **Mitigation**: Require multi-file investigation
- **Mitigation**: Make conflicts require analysis, not just upgrade

**Risk**: Agent can bypass by removing tests
- **Mitigation**: Hidden tests verify functionality
- **Mitigation**: Test count validation

**Risk**: Partial fixes pass some tests
- **Mitigation**: All success criteria must be met
- **Mitigation**: Hidden tests catch partial repairs

---

## 7. Implementation Timeline

### Phase 1: Environment Setup
1. Create Dockerfile for task environment
2. Install all required system packages
3. Configure Python 3.11 environment

### Phase 2: Broken Repository Creation
1. Create project structure
2. Implement working application code (src/)
3. Create passing tests (tests/)
4. Introduce Problem 1: Dependency conflicts in requirements.txt
5. Introduce Problem 2: Invalid pyproject.toml
6. Introduce Problem 3: Broken Dockerfile
7. Introduce Problem 4: CI configuration drift

### Phase 3: Test Suite Development
1. Create public tests (docker build, install, pytest)
2. Create hidden tests (clean install, stability, regression, reproducibility)
3. Verify tests fail on broken repo
4. Verify tests pass on fixed repo

### Phase 4: Oracle Solution
1. Create solve.sh with minimal fixes
2. Document each fix with comments
3. Validate solve.sh restores full functionality

### Phase 5: Task Metadata
1. Create instruction.md (problem statement only)
2. Create task.toml (metadata)
3. Final validation of complete task

### Phase 6: Quality Assurance
1. Full docker build of task environment
2. Complete test suite execution
3. Oracle solution execution
4. Verify deterministic behavior

---

## 8. Success Criteria for Implementation

- [ ] Docker environment builds successfully
- [ ] Broken repository exhibits all 4 problems
- [ ] Public tests fail on broken repo
- [ ] Oracle solution fixes all problems
- [ ] All tests pass after oracle solution
- [ ] Hidden tests verify true repair (not workarounds)
- [ ] Task is reproducible in clean environment
- [ ] Instruction.md reveals only problem, not solution

---

## 9. File Content Specifications

### instruction.md (Final)
Will contain only the problem scenario from task_specification.md Section 1, without revealing:
- Which files are broken
- What specific fixes are needed
- Test locations
- Oracle behavior

### task.toml
```toml
name = "broken-python-build-system-recovery"
difficulty = "hard"
category = "software-engineering"
language = "python"
tags = ["build-system", "dependency-management", "docker", "ci-cd"]
time_limit = 3600  # seconds
memory_limit = 4096  # MB
```

### Initial Broken State Examples

**requirements.txt (broken)**:
```
package-a==1.0.0  # requires urllib3<2
package-b==2.0.0  # requires urllib3>=2
# This creates ResolutionImpossible
```

**pyproject.toml (broken)**:
```toml
[build-system]
requires = ["setuptools<45"]  # Too old, incompatible
build-backend = "old_backend"  # Doesn't exist
```

**Dockerfile (broken)**:
```dockerfile
FROM python:3.8  # Wrong version
WORKDIR /wrong/path
RUN pip install -r requirements.txt  # Before installing build deps
COPY . .
```

**ci.yml (broken)**:
```yaml
python-version: "3.8"  # Wrong version
env:
  DEPRECATED_VAR: value  # Removed variable
```

---

This implementation plan provides a complete blueprint for creating a realistic, challenging Terminal-Bench task that evaluates an AI agent's ability to debug and repair a broken Python build system.
