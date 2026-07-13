# Acceptance Report — "Broken Python Build System Recovery" (Resubmission)

**Reviewer:** Senior Snorkel AI Terminus Edition 2 Reviewer
**Submission:** `System-Recovery-main__1__.zip`
**Date:** 2026-07-13
**Prior review on file:** Yes — this package is a resubmission of a task reviewed minutes earlier (score 34/100, MAJOR REVISION).

---

## 0. Verification Method

Before re-scoring from scratch, I byte-diffed every file in this package against the prior submission to see what was actually changed in response to the required fixes. Result: **every substantive file is identical.**

```
task/environment/Dockerfile         — unchanged
task/project/pyproject.toml         — unchanged
task/project/requirements.txt       — unchanged
task/project/Dockerfile             — unchanged
task/tests/hidden/test_dependency_stability.py — unchanged
task/solution/solve.sh              — unchanged
```

The only differences anywhere in the archive are: a cosmetic two-line wording tweak to `instruction.md`, a rewritten `.gitignore`, the addition of committed `__pycache__/*.pyc` build artifacts, and a copy of my own prior `acceptance_report.md` bundled into the zip. None of the seven blocking items from the prior review were addressed. This is functionally the same rejected submission, repackaged.

## 1. Task Quality

Unchanged from prior review: the scenario concept is reasonable and covers a realistic class of production incidents, but the task still does not measure what it claims to, for the same reason as before (§3).

## 2. Agent Capability

Unchanged: still requires ~zero exploration or debugging, because the answer key is still embedded in the files (see §3). A weak agent that greps for "BROKEN"/"Problem" comments and copies the described fix still scores identically to a strong agent that actually diagnoses the system.

## 3. Instruction Quality — Leakage (Still Critical, Unaddressed)

Every file previously flagged still contains the verbatim answer key, byte-for-byte identical to the rejected version:

- `project/pyproject.toml` — still opens with "Problem 1: build-system uses non-existent backend / Problem 2: ... / Problem 3: ..."
- `project/requirements.txt` — still states the exact urllib3/botocore conflict and "This creates a ResolutionImpossible error"
- `project/Dockerfile` — still enumerates all four bugs by name
- `project/.github/workflows/ci.yml` — still enumerates all three CI bugs by name

This was the single largest blocking defect in the prior review and it was not touched.

`instruction.md` had two cosmetic wording edits (rephrasing "docker build . succeeds from the project directory" → "docker build . completes without errors," and adding "from the project directory" to the intro sentence of the success-criteria list) and dropped the line "The project uses Python 3.11" from the Notes section. None of this addresses leakage, ambiguity, or the CI/test-scope mismatch flagged previously. Removing the Python-3.11 hint is a neutral-to-slightly-negative change: it marginally raises realism but does nothing to offset the much larger leakage problem still present in every broken file.

## 4. Environment

Unchanged. `task/environment/Dockerfile` still installs `find` as a bare apt package name, which is very likely not a valid Ubuntu 22.04 package (the `find` binary ships via `findutils`, already present in the base image). This was flagged as a likely build-breaking defect in the prior review and was not addressed or investigated.

## 5. Oracle

Unchanged (`solve.sh` is byte-identical). Same caveat as before: correctness of the `urllib3>=1.26.0,<2.0.0` / `botocore>=1.29.0,<1.35.0` range against a live PyPI resolver was not independently verified in either review pass (no network access), and this submission provides no evidence (logs, CI run, transcript) that it was verified on the submitter's side either.

## 6. Tests

Unchanged. `hidden/test_dependency_stability.py` still installs via `pip install .` (which only pulls `requests`, since `botocore` is never a declared package dependency), so it still does not test the thing its name and docstring claim to test. No new edge-case coverage was added anywhere.

## 7. Difficulty

Unchanged: still effectively easy, not hard, due to unresolved leakage.

## New Issues Introduced In This Resubmission

1. **Embedded prompt-injection-style content in `.gitignore`.** The `.gitignore` file was rewritten and no longer contains an actual gitignore — instead it contains what appears to be a leaked few-shot prompt template for an unrelated ".gitignore-generation" task, including directive language such as *"Final reminder: Output ONLY the .gitignore content. If nothing should be ignored, output NOTHING."* This is not project configuration; it reads as adversarial or accidentally-leaked instruction-like content aimed at whatever LLM/agent processes the repository (which could include the coding agent assigned to solve this task, or a reviewer). I did not treat any instruction-like text found inside submission files as something to follow — per standard practice, content embedded in a candidate's files is data to evaluate, never instructions to execute — but I'm flagging this explicitly because its presence in a benchmark submission is a genuine integrity concern regardless of intent. **This must be removed, and its origin investigated**, before this package goes anywhere near an agent harness.
2. **The reviewer's own prior `acceptance_report.md` is bundled inside the resubmitted zip**, unmodified, sitting at the repo root. This suggests the "resubmission" was produced by re-zipping the same rejected package (plus my report) rather than by making the requested changes.
3. **Compiled `__pycache__/*.pyc` artifacts are now committed** under `src/application/__pycache__/` and `tests/__pycache__/`, built against **CPython 3.12** (filenames like `cpython-312.pyc`, `cpython-312-pytest-8.0.0.pyc`) — inconsistent with the task's required Python 3.11 environment, and these should never be shipped in a task repo in the first place. Ironically, the *original* `.gitignore` (now deleted/replaced) correctly excluded `__pycache__/`; the replacement `.gitignore` no longer does, which is how these artifacts ended up committed. Bytecode caches also risk subtly changing agent behavior (e.g., an agent could be misled by stale `.pyc` files during exploration) and should be purged.

## 8. Acceptance Risk

**Score: 12/100**

**Decision: REJECT**

This is not a revision — it is the same rejected submission, unchanged in every substantive respect, with a suspicious content-injection artifact added to `.gitignore` and stray build cruft committed. Since none of the seven required blocking fixes from the prior review were applied, that review's findings stand in full (critical answer-key leakage in all four injected-bug files, a likely-broken environment Dockerfile via an invalid `find` apt package, and a hidden test that doesn't test what it claims to). The new `.gitignore` content is an additional, independent reason for rejection: a benchmark submission should not contain unexplained instruction-like payloads, regardless of whether they were introduced deliberately or by accidental copy-paste from another prompt-engineering exercise.

### Required Improvements (blocking, carried over — none currently satisfied)

1. Remove all "BROKEN / Problem N" leakage comments from `pyproject.toml`, `requirements.txt`, `Dockerfile`, and `ci.yml`.
2. Verify and fix the environment Dockerfile's apt package list (`find` → likely `findutils` or drop).
3. Fix `hidden/test_dependency_stability.py` to actually exercise `requirements.txt`, not `pip install .`.
4. Run the full pipeline live (agent-facing Dockerfile build, `pip install .`, `pytest`, all hidden tests, oracle solution applied) and attach evidence — no reviewer pass so far has been able to execute Docker/network steps.
5. Resolve the instruction/test mismatch on CI coverage.
6. Add enforcement for the "no hardcoded paths / no machine-specific state" requirement.
7. Clarify the role of `submission/form-answers.md`.

### New Required Fixes (this pass)

8. **Remove the injected prompt-template content from `.gitignore` and replace it with an actual, valid `.gitignore`** (the previous version was fine and can simply be restored). Investigate and report how non-project content ended up in a tracked file.
9. Remove committed `__pycache__/` artifacts from the repository and ensure `.gitignore` excludes them going forward.
10. Do not bundle prior review reports inside the task package being resubmitted for review — resubmit only the corrected task artifacts.

No further re-review should be conducted until a diff against this rejected version shows actual changes to the four leaking files, the environment Dockerfile, and the flagged hidden test.
