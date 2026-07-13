# Broken Python Build System Recovery

## Scenario

You are an engineer responsible for restoring a broken Python project.

A previously working internal Python service has stopped building after a recent dependency maintenance cycle.

The repository currently fails during installation, Docker image creation, and CI execution.

## Your Goal

Investigate the repository, identify the causes of the failures, and restore the project so that it can:

- Build successfully inside Docker
- Install as a Python package
- Run the existing test suite
- Work reliably in a clean environment

## Repository Location

The project is located at `/workspace/project`.

## Requirements

1. **Do not remove tests or bypass failures** - Tests represent required behavior
2. **Make only necessary repository changes** - Fix the root causes, not symptoms
3. **Ensure reproducibility** - The solution must work in any clean environment
4. **Validate your changes** - Test thoroughly before finishing

## Success Criteria

Your solution is complete when all of the following commands succeed from the project directory:

- `docker build .` completes without errors
- `pip install .` installs the package without errors
- `pytest` runs all tests successfully
- The solution works in a fresh environment (no cached dependencies or machine-specific state)

## Notes

- All fixes must be committed to repository files (not just local environment changes)
- Avoid hardcoded absolute paths
- Do not depend on developer machine state

Begin by exploring the repository structure and reproducing the failures.
