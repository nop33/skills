---
name: testing
description: Rules for tests worth keeping, for writing them and for reviewing them. Use when writing, changing or deleting tests, fixing a bug test-first, or auditing an existing test suite for weak, tautological or implementation-coupled tests.
---

# Testing

A test is worth keeping when it fails if the behavior breaks and passes if the behavior is right. How the code works inside must not change the result. The rules below follow from that.

## What a good test is

A good test calls the code the way its callers do, through the public interface, and asserts the exact result they see. It never reaches inside the code. That means no calls to private functions, no checks on internal state, and no database queries when the interface returns the same information. You can rewrite all the code behind the interface and the test still passes.

The expected value comes from a source independent of the code, such as a literal, a worked example, the spec or a known-good output. Never compute it the way the code computes it.

[tests.md](tests.md) has good and bad examples. [mocking.md](mocking.md) explains when to mock.

## The check

For every test, ask whether it would still pass if the code under test returned `undefined` or a wrong value. If it would, the test proves nothing. Rewrite it or delete it.

## Anti-patterns

- **Implementation-coupled.** The test mocks your own modules, calls private functions, asserts call counts on internal collaborators, or reads state the interface doesn't expose. It fails after a refactor that no caller would notice.
- **Tautological.** The test computes the expected value the same way the code does, as in `expect(add(a, b)).toBe(a + b)` or a total recomputed with the same `reduce`. It can't fail, because both sides come from the same calculation.
- **Loose assertion.** The test uses `toBeDefined`, `toBeTruthy`, `not.toThrow` with nothing else, `toBeGreaterThan(0)` when the exact value is known, or `toEqual([])` with no other check. Many wrong results pass it.
- **Test-built data.** The test asserts on objects it constructed itself and never calls the code under test.
- **Restated constant.** The test asserts that a config value or a string equals itself. Test the code that reads the constant instead.

## Mocks

Mock only at system boundaries, such as external APIs, time, randomness, and sometimes the file system or the database. Never mock code you own.

At a boundary, assert exactly what your code sent: the payload, the rows written, the arguments to the external call. When a test asserts that a call did not happen, another test must show the call happening for a different input.

## When not to write a unit test

Config, wiring and code that only passes values along have no independent source of truth, so any unit test of them restates the implementation. Say so and skip the test. Test the behavior that depends on that code instead.

## Writing tests

1. Name each test after the behavior a caller sees, such as "an edit during a slow push stays queued", not after the function or the mechanism.
2. Test one behavior per test.
3. For a bug fix, write the test that reproduces the bug first, and check that it fails for the reason the bug report describes. Then fix the code.
4. Prove each new test can fail. If you didn't see it fail before the code existed, break the code on purpose, check that the test fails, then restore the code.
5. Run the test and the suite around it before you report the work as done.

## Reviewing tests

Review in a new session or a subagent, never in the session that wrote the tests. An agent that reviews its own tests repeats the assumptions it wrote them with.

1. Read each test against the check and the anti-patterns above. A search for loose matchers finds candidates, not verdicts, so read every hit in context. A loose matcher next to an exact assertion can be fine.
2. Give every test that needs action one of three verdicts:
   - **Strengthen** when the test covers the right behavior with a weak assertion.
   - **Rewrite** when it covers the right behavior the wrong way.
   - **Delete** when it proves nothing or duplicates another test.

   Leave good tests out of the report.
3. For each verdict, cite `file:line`, name the rule the test breaks, and give the concrete fix, such as the exact value to assert.
4. Change nothing unless asked. When asked to apply fixes, prove each changed test can fail, as in step 4 of writing tests.
