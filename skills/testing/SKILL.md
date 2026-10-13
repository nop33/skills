---
name: testing
description: Rules for tests worth keeping, for writing them and for reviewing them. Use when writing, changing or deleting tests, fixing a bug test-first, or auditing an existing test suite for weak, tautological or implementation-coupled tests.
---

# Testing

Test through the public interface the way callers use it, and assert the exact result they see, taken from a source independent of the code: a literal, a worked example, the spec. [tests.md](tests.md) has good and bad examples, and [mocking.md](mocking.md) says what to mock.

## The check

For every test, ask whether it would still pass if the code under test returned `undefined` or a wrong value. If it would, the test proves nothing. Rewrite it or delete it.

## Anti-patterns

- **Implementation-coupled.** The test mocks your own code, calls private functions or reads state the interface doesn't expose, so it fails after a refactor no caller would notice.
- **Tautological.** The test computes the expected value the way the code does, so both sides always agree.
- **Loose assertion.** The test uses `toBeDefined`, `toBeTruthy`, `not.toThrow` with nothing else, `toBeGreaterThan(0)` when the exact value is known, or `toEqual([])` with no other check.
- **Test-built data.** The test asserts on objects it constructed and never calls the code under test.
- **Restated constant.** The test asserts that a config value or string equals itself. Test the code that reads it instead.

At a mocked boundary, assert exactly what your code sent: the payload, the rows written, the arguments. When a test asserts that a call did not happen, another test must show it happening for a different input.

Config, wiring and code that only passes values along have no independent source of truth, so a unit test of them restates the implementation. Skip it, say why, and test the behavior that depends on that code.

## Writing tests

1. Name each test after the behavior a caller sees, such as "an edit during a slow push stays queued".
2. For a bug fix, write the test that reproduces the bug first, and check that it fails for the reason in the bug report.
3. Prove each new test can fail. If you didn't see it fail before the code existed, break the code on purpose, check that the test fails, then restore the code.
4. Run the test and the suite around it before you report the work as done.

## Reviewing tests

Review in a new session or a subagent, never in the session that wrote the tests, which shares their assumptions.

1. Read each test against the check and the anti-patterns. A search for loose matchers only finds candidates. A loose matcher next to an exact assertion can be fine.
2. Give each test that needs action a verdict, and leave good tests out of the report:
   - **Strengthen** when it covers the right behavior with a weak assertion.
   - **Rewrite** when it covers the right behavior the wrong way.
   - **Delete** when it proves nothing or duplicates another test.
3. Cite `file:line`, name the rule it breaks, and give the concrete fix, such as the exact value to assert.
4. Change nothing unless asked. When applying fixes, prove each changed test can fail.
