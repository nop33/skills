---
name: testing
description: Rules for tests worth keeping, for writing them and for reviewing them. Use when writing, changing or deleting tests, fixing a bug test-first, or auditing an existing test suite for weak, tautological or implementation-coupled tests.
---

# Testing

A test is worth keeping when it fails if the behavior breaks and passes when the behavior is right, however the code is written inside. The rules below all follow from that.

## What a good test is

A good test calls the code the way its callers do, through the public interface, and asserts the exact result they see. It never reaches inside: no private functions, no internal state, no checking the database when the interface can answer. The code behind the interface can be rewritten entirely and the test stays green.

The expected value comes from somewhere independent of the code: a literal, a worked example, the spec, a known-good output. Never compute it the way the code computes it.

See [tests.md](tests.md) for good and bad examples, and [mocking.md](mocking.md) for when to mock.

## The check

For every test, ask whether it would still pass if the code under test returned `undefined` or a wrong value. If it would, the test proves nothing. Rewrite it or delete it.

## Anti-patterns

- **Implementation-coupled.** The test mocks your own modules, calls private functions, asserts call counts on internal collaborators, or verifies through a side channel. It breaks when you refactor even though no caller would notice a difference.
- **Tautological.** The expected value repeats the implementation, as in `expect(add(a, b)).toBe(a + b)` or a total recomputed with the same `reduce`. It passes by construction.
- **Loose assertion.** `toBeDefined`, `toBeTruthy`, `not.toThrow` on its own, `toBeGreaterThan(0)` where the exact value is known, `toEqual([])` with no other check. It passes for many wrong results.
- **Test-built data.** The test asserts on objects it constructed itself and never calls the code under test.
- **Restated constant.** The test asserts that a config value or a string equals itself. Test the code that reads the constant instead.

## Mocks

Mock only at system boundaries: external APIs, time, randomness, sometimes the file system or the database. Never mock code you own.

At a boundary, assert exactly what crossed it: the payload sent, the rows written, the arguments to the external call. For "nothing happened", assert the exact absence and make sure another test shows the same thing happening on a different input.

## When not to write a unit test

Config, wiring and code that only passes values along have no independent source of truth, so any unit test restates the implementation. Say so and skip it. Cover that code through a test of the behavior that depends on it.

## Writing tests

1. Name each test after the behavior a caller sees ("an edit during a slow push stays queued"), not after the function or the mechanism.
2. Test one behavior per test.
3. For a bug fix, write the test that reproduces the bug first and watch it fail for the reason the bug report describes. Then fix the code.
4. Prove each new test can fail. If you didn't watch it fail before the code existed, break the code on purpose, see the test go red, then restore it.
5. Run the test and the suite around it before calling the work done.

## Reviewing tests

Review in a fresh context: a new session or a subagent, never the session that wrote the tests. An agent reviewing its own tests confirms its own assumptions.

1. Read each test against the check and the anti-patterns above. A search for loose matchers finds candidates, not verdicts, so read every hit in context. A loose matcher next to an exact assertion can be fine.
2. Give every test that needs action a verdict: **strengthen** (right test, weak assertion), **rewrite** (right behavior, wrong approach) or **delete** (proves nothing, or duplicates another test). Leave good tests out of the report.
3. Cite `file:line`, name the rule it breaks, and give the concrete fix, such as the exact value to assert.
4. Change nothing unless asked. When asked to apply fixes, prove each changed test can fail, as in step 4 of writing tests.
