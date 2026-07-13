Filesystem Metadata Reconstruction
Software Architecture & Implementation Specification
For Snorkel AI Terminus Edition 2
Terminal-Bench Style Benchmark
Difficulty: Hard
Primary Language: Haskell
Deliverables

The implementation must produce the following repository:

instruction.md
task.toml

environment/
solution/
tests/

submission/
form-answers.md

The implementation must include:

Docker environment
Oracle solution
Visible tests
Hidden tests
Deterministic evaluation
CI validation
Golden/Oracle verification
NOP verification

The implementation must not omit any required benchmark component.

Complete Engineering Specification
Volume I
Project Foundation

Approximately 40 pages.

Contents:

Benchmark Vision
Benchmark Philosophy
Scientific Motivation
AI Capability Model
Human Capability Model
Difficulty Calibration
Acceptance Criteria
Reviewer Expectations
Deliverables
Repository Blueprint
Complete Directory Architecture
Repository Lifecycle
Data Flow
Execution Flow
Benchmark Constraints
Engineering Assumptions
Volume II
Environment Engineering

Approximately 60 pages.

Contents:

Docker Architecture
Container Design
Runtime Architecture
Bootstrap Workflow
Filesystem Layout
Archive Dataset Design
Metadata Repository Design
Seed Data
Corruption Generator
Validation Utilities
CLI Specifications
Logging Architecture
Configuration System
Environment Variables
Permission Model
Security Model

Every directory is specified.

Every runtime component is specified.

Volume III
Software Architecture

Approximately 120 pages.

This is the largest document.

Every file is designed individually.

For every source file define:

Purpose
Responsibilities
Inputs
Outputs
Dependencies
File Access
Public Interface
Internal Modules
Data Structures
Error Handling
Logging
Performance Requirements
Unit Testing Requirements
Hidden Test Coverage
Oracle Usage

Then continue to:

Module Design
Class Design
Function Design
Interface Design
Data Model
JSON Schema
Validation Rules
Metadata Schema

Nothing is left unspecified.

Volume IV
Benchmark Logic

Approximately 80 pages.

Contents:

Failure Injection Strategy
Corruption Generator
Oracle Design
Oracle Workflow
Oracle Validation
Agent Workflow
Expected Agent Reasoning
Hidden Constraints
Anti-Cheating Design
Security Validation
Edge Cases
Visible Tests
Hidden Tests
Regression Tests
Performance Tests
Integrity Tests
Determinism Tests

Every hidden test is described.

Every corruption pattern is described.

Every oracle phase is specified.

Volume V
Implementation & Submission Guide

Approximately 40 pages.

Contents:

CI Validation Pipeline
Build Pipeline
Docker Validation
Oracle Verification
NOP Verification
Determinism Verification
Acceptance Checklist
Reviewer Checklist
Submission Checklist
instruction.md Specification
task.toml Specification
environment/ Specification
solution/ Specification
tests/ Specification
submission/form-answers.md Specification
Common Failure Modes
Acceptance Risk Analysis
Design Depth

Every directory is designed.

↓

Every file is designed.

↓

Every module is designed.

↓

Every class is designed.

↓

Every function is designed.

↓

Every data structure is designed.

↓

Every JSON schema is designed.

↓

Every CLI interface is designed.

↓

Every validation rule is designed.

↓

Every hidden test is designed.

↓

Every oracle step is designed.

↓

Every CI step is designed.

↓

Every submission artifact is designed.

The coding agent should never have to invent architecture.

Mandatory Implementation Workflow

The implementation agent must follow this exact sequence:

Study this Software Architecture Specification.
Produce a detailed implementation plan derived from the specification.
Present the plan for review.
Wait for approval before creating files.
Create the repository skeleton.
Implement the Docker environment.
Implement the archive dataset and metadata system.
Implement validation utilities.
Implement corruption injection.
Implement the oracle solution.
Implement visible tests.
Implement hidden tests.
Implement CI validation.
Execute Golden/Oracle verification.
Execute NOP verification.
Verify deterministic behavior across repeated runs.
Generate all required deliverables.
Complete submission/form-answers.md.
Perform a final compliance review against the Terminus Edition 2 requirements.
Target Quality Standard

This specification targets:

Difficulty: Hard
Primary Language: Haskell
Execution Environment: Offline, deterministic Docker
Benchmark Style: Terminal-Bench
Evaluation Philosophy: Outcome-based with hidden validation
Acceptance Goal: Maximize the probability of acceptance under the Snorkel AI Terminus Edition 2 review process while creating a scientifically valuable benchmark that measures autonomous systems engineering rather than simple code generation.
