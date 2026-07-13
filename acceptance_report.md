# Acceptance Report — "Broken Python Build System Recovery"

**Reviewer:** Senior Snorkel AI Terminus Edition 2 Reviewer
**Submission:** `System-Recovery-main.zip`
**Date:** 2026-07-13

---

## 1. Task Quality

The underlying scenario (a Python service broken by a "dependency maintenance cycle" — bad `pyproject.toml`, conflicting pins, a mis-ordered Dockerfile, CI drift) is a realistic and well-scoped class of production incident. On paper it touches four distinct, genuinely common failure modes (packaging metadata, dependency resolution, container build order, CI config drift), which is good breadth for a single task.

In practice, however, the task does **not** measure what it claims to, because of a critical leakage defect (§3). As implemented, it measures "can the agent read code comments and copy the fix described in them," not "can the agent diagnose a broken build system." This is a fundamental quality problem, not a polish issue.

## 2. Agent Capability

The task *design* nominally requires exploration, reasoning, debugging, and multi-file implementation. The task *as shipped* requires almost none of that:

- No log-reading or resolver-error interpretation is needed — the comment in `requirements.txt` already states the exact conflict ("botocore 1.34.0 requires urllib3>=1.25.4,<1.27 ... urllib3==1.26.18 ... ResolutionImpossible").
- No Dockerfile debugging is needed — the comment enumerates all four bugs by name.
- No packaging investigation is needed — `pyproject.toml`'s comment names the exact three problems (bad backend, invalid fields, dependency reference).

A competent agent can solve this task with `grep -rn BROKEN .` and a templated rewrite, skipping the "reproduce → diagnose → fix → validate" loop entirely. This collapses the intended difficulty from "hard, multi-system debugging" to "easy, pattern-completion." A weak agent that merely regurgitates each file's own comments back as code will score as well as a strong agent that actually reasons about the failures.

## 3. Instruction Quality — Leakage (Critical)

`task_specification.md` (the design doc bundled with this submission) is explicit that the instruction — and by clear implication the environment — **must not reveal**:

> "broken files, expected fixes, dependency conflicts, hidden tests, oracle behavior, exact commands required."

`instruction.md` itself honors this. **But every single injected-defect file that is copied into the agent's workspace violates it directly:**

| File | Leakage |
|---|---|
| `project/pyproject.toml` | Header comment: "Problem 1: build-system uses non-existent backend / Problem 2: project metadata has invalid fields / Problem 3: dependencies reference the broken requirements.txt" |
| `project/requirements.txt` | Header comment spells out the exact urllib3/botocore version conflict and states "This creates a ResolutionImpossible error" |
| `project/Dockerfile` | Header comment: "Problem 1: Wrong Python base image version... Problem 2: Missing build-essential... Problem 3: Incorrect WORKDIR... Problem 4: Wrong installation order" |
| `project/.github/workflows/ci.yml` | Header comment: "Problem 1: Wrong Python version... Problem 2: Deprecated/removed environment variable... Problem 3: Invalid cache configuration" |

This is not a minor hint — it is the answer key, verbatim, sitting in the files the agent is told to fix. Every one of the four "problems" the spec says the agent must discover through investigation is instead handed to it on line 1. This must be fixed before the task can be considered a valid measure of debugging ability (see Required Improvements).

Beyond leakage, one ambiguity: `instruction.md` says the repo "fails during installation, Docker image creation, **and CI execution**," but no public or hidden test ever executes or validates `.github/workflows/ci.yml`. The oracle fixes it anyway (scope creep relative to the graded success criteria). This should be clarified — either grade CI, or stop telling the agent it matters.

## 4. Environment

- The environment `Dockerfile` (`task/environment/Dockerfile`) installs an apt package list that includes `find` as a standalone package name:
  ```
  RUN apt-get install -y ... grep sed find tree build-essential ...
  ```
  There is no Ubuntu/Debian package literally named `find` (the `find` binary ships in `findutils`, which is already present as an essential package in the Ubuntu base image). If confirmed on a live build, `apt-get install -y find` will fail with `Unable to locate package find` and the **harness environment itself will not build**, independent of anything the agent does. This needs to be verified against a live `docker build` and corrected (drop `find` or replace with `findutils`) before acceptance.
- Aside from that, the environment is otherwise well constructed: pinned tool versions (`pytest==8.0.0`, `build==1.0.3`, `pip-tools==7.3.0`, `setuptools==69.0.3`, `wheel==0.42.0`) for reproducibility, `DEBIAN_FRONTEND=noninteractive`, apt list cleanup, and a clean separation — only `project/` is copied into the agent's workspace, so `solution/`, `tests/hidden/`, and `task_specification.md`/`implementation_plan.md` are not exposed. That separation is correctly designed (modulo the comment-leakage inside `project/` itself).

## 5. Oracle

- The oracle script (`solution/solve.sh`) is a reasonable, minimal, believable fix: modern `setuptools.build_meta` backend, `requires-python = ">=3.11"`, corrected Dockerfile layer order (deps before code, correct base image, correct `WORKDIR`), and range-based (not exact-pinned) `urllib3`/`botocore` versions.
- **Correctness cannot be confirmed in this review environment** (no network access to run `pip install` / `pip download --dry-run` against PyPI, or to run `docker build`). Before acceptance, the oracle must actually be executed end-to-end (`docker build .`, `pip install .`, `pytest`, plus all four hidden tests) against a live Ubuntu 22.04 / Python 3.11 environment to confirm the `urllib3>=1.26.0,<2.0.0` / `botocore>=1.29.0,<1.35.0` combination truly resolves — botocore's urllib3 constraint has historically varied by Python version and botocore release, and this range was not independently verified here.
- **Design gap that weakens the oracle's own test coverage:** `pyproject.toml`'s `[project.dependencies]` only lists `requests`. `botocore` (the package that supposedly causes the injected conflict) never appears as a declared package dependency — it only appears in `requirements.txt`, which is consumed by the *Dockerfile* (`pip install -r requirements.txt`) but not by `pip install .`. That means `hidden/test_dependency_stability.py`, which does a fresh `pip install .` and then inspects `pip freeze` for `urllib3`, is not actually exercising the conflict it claims to validate — it will pass regardless of whether `requirements.txt` was fixed correctly, because `botocore` is never installed via that path. The real test of the requirements.txt fix is buried inside `test_docker_build.py`/`test_docker_reproducibility.py`, not the test whose name and docstring claim to own that concern.

## 6. Tests

Coverage is reasonably broad in *shape* — public tests for docker build, pip install, and pytest; hidden tests for clean-venv install, dependency stability, functional regression, and docker reproducibility. Positives:
- Uses real subprocess-level black-box checks (build the actual image, install in a genuinely fresh venv) rather than trusting agent self-report — good against superficial fixes.
- `test_docker_reproducibility.py` guards against non-deterministic/cache-dependent builds, a nice touch matching a stated failure condition.

Weaknesses:
- As noted in §5, `test_dependency_stability.py` doesn't actually validate the thing it's named for.
- `hidden/test_regression.py`'s `test_config_functionality` and `test_utils_functionality` largely duplicate assertions already present verbatim in the visible `tests/test_config.py` / `tests/test_core.py` — they add re-execution-in-a-fresh-venv value, but no new edge cases (e.g. no test for `sanitize_string` on unicode/mixed input, no test for `Config.validate()` boundary at `max_retries == 0`, no CLI/`__main__` invocation test).
- No test enforces the "no hardcoded absolute paths" / "no machine-specific state" requirement that `instruction.md` and `task_specification.md` explicitly call out as a failure condition — this is currently unenforced and would let a weak agent pass while violating a stated requirement.
- No test validates the CI YAML at all, despite the instruction telling the agent CI execution is currently failing (see §3).
- `submission/form-answers.md` is a blank human-readable checklist with no evident automated consumer — unclear whether/how it factors into grading. If it's vestigial, remove it to avoid ambiguity about what's actually graded.

## 7. Difficulty

Labeled `difficulty = "hard"` in `task.toml`, and the *design intent* (4 independent multi-file failures, resolver-level dependency conflict, container build ordering) would plausibly justify that label. As shipped, due to the in-file answer-key comments (§3), the actual difficulty is closer to **trivial-to-easy**: locate four commented files, apply the described fix, verify. The difficulty label is not honest about what's being measured until leakage is removed.

## 8. Acceptance Risk

**Score: 34/100**

**Decision: MAJOR REVISION**

The task concept, harness structure (environment/tests/solution/submission separation), and test black-box philosophy are sound and worth keeping. But the submission cannot be accepted in its current form because of one disqualifying defect (in-file leakage of every injected bug, contradicting the design doc's own explicit non-leakage requirement) plus one likely environment-breaking defect (`find` apt package) and one test-validity gap (dependency-stability test doesn't test what it claims to). These are correctness/validity issues, not style nits.

### Required Improvements (blocking)

1. **Remove all leakage comments** from `project/pyproject.toml`, `project/requirements.txt`, `project/Dockerfile`, and `project/.github/workflows/ci.yml`. Replace with either no comments, or comments that would plausibly exist in a real broken production repo (e.g. stale TODOs, unrelated notes) — never a description of the injected bug or its fix.
2. **Verify and fix the environment Dockerfile's apt package list** — confirm whether `find` is installable as-is on `ubuntu:22.04`; if not, replace with `findutils` or drop it (the base image already provides `find`).
3. **Fix or repurpose `hidden/test_dependency_stability.py`** so it actually exercises the `requirements.txt` conflict (e.g., run `pip install -r requirements.txt` in a fresh venv, not `pip install .`), or rename/reframe it to match what it truly tests.
4. **Run the full pipeline live** (`docker build .`, `pip install .`, `pytest`, all four hidden tests) with the oracle solution applied, end-to-end, on a real Ubuntu 22.04 + Python 3.11 machine, and attach the transcript/logs as evidence — this review could not execute Docker/network-dependent steps and cannot certify oracle correctness from static reading alone.
5. **Resolve the instruction/test mismatch on CI**: either add a test that validates `.github/workflows/ci.yml` (e.g., `actionlint`, or a matrix-version assertion), or remove CI from the failure description in `instruction.md` so the stated scope matches the graded scope.
6. **Add a test (or explicit grading rubric line) for the "no hardcoded paths / no machine-specific state" requirement**, since it's stated as a hard failure condition but currently unenforced.
7. Decide the role of `submission/form-answers.md` — either wire it into grading or remove it to avoid confusion about what's actually assessed.

Once items 1–4 are addressed (leakage removal, environment fix, dependency test fix, live verification), this task has a solid chance of being a genuinely good hard-difficulty benchmark item and should be resubmitted for re-review rather than rebuilt from scratch.
