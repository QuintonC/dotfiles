---
name: pls-test-bed
description: Generate comprehensive Ruby (RSpec/Minitest) tests for a specific file or for uncommitted changes, following existing project conventions. Use when the user asks to write, generate, or back-fill Ruby/Rails tests, or mentions "pls test" for backend/Ruby code.
---

# Ruby Test Generator (backend)

Generate comprehensive Ruby tests following project conventions and best practices.

## Target selection

- If a file path is provided as an argument, generate tests for that file (e.g. `app/models/user.rb`, `lib/services/auth.rb`).
- If no path is given, target the uncommitted changes. Run `git diff --name-only` and `git diff --cached --name-only` via the `bash` tool to find changed Ruby files, then read those files.

## What it does

1. Analyze the target code (file or uncommitted changes).
2. Examine existing test patterns in the codebase.
3. Generate tests that match project conventions.
4. Create meaningful test cases with clear descriptions.
5. Write tests to the appropriate test file location.

## Test Generation Principles

### Ruby Best Practices

- Use descriptive test names that explain behavior.
- Follow AAA pattern (Arrange, Act, Assert).
- Test behavior, not implementation.
- Prefer integration over unit tests where sensible.
- Use factories or fixtures consistently with the project.

### Mocking Philosophy

- Avoid unnecessary mocking.
- Mock external dependencies only.
- Prefer real objects and database transactions.
- Use stubs sparingly for expensive operations.
- Never mock the system under test.

### Coverage Guidelines

- Test the happy path thoroughly.
- Include edge cases and boundary conditions.
- Test error handling and exceptions.
- Validate data transformations.
- Check side effects where applicable.

## Output Structure

Match the existing project structure:

- RSpec: `describe/context/it` blocks.
- Minitest: `class` / `def test_` methods.
- Test names clearly describe expected behavior.
- Setup/teardown follows project patterns.
- Assertions use the project's preferred matchers.

## Requirements

- Identify the test framework in use (RSpec, Minitest, etc.) before writing.
- Analyze existing test files for patterns first.
- Save output to the appropriate `spec/` or `test/` directory.
- Follow the project's test file naming convention.

## Examples

For a **model**, generate tests for:

- Valid/invalid record creation
- Associations and validations
- Scopes and class methods
- Instance methods and callbacks
- Edge cases for business logic

For a **service object**, generate tests for:

- Success and failure paths
- Input validation
- Expected return values
- Side effects (emails, jobs, etc.)
- Error handling scenarios

## Notes

- Match the indentation and style of existing tests.
- Use existing factories, fixtures, or helpers.
- Include necessary test setup/teardown.
- Comments only for complex setup scenarios.
- Focus on readability and maintainability.
