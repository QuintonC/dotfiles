---
name: pls_test_fed
description: Analyze test coverage and write comprehensive frontend tests
arguments:
  - name: file_path
    description: Path to file to analyze and test (optional, defaults to git diff)
    required: false
allowed-tools: Bash(git diff:*), Bash(git diff --cached:*)
---

# Frontend Test Coverage Command

Analyze test coverage for a given file and write comprehensive tests following expert frontend conventions.

## Target

```
$ARGUMENTS
```

If no target file is specified above, use the changed files from the context below.

# Context

- Changed frontend files (unstaged): !`git diff --name-only -- '*.ts' '*.tsx' '*.js' '*.jsx' | grep -v -E '\.(test|spec)\.' || true`
- Changed frontend files (staged): !`git diff --cached --name-only -- '*.ts' '*.tsx' '*.js' '*.jsx' | grep -v -E '\.(test|spec)\.' || true`
- Git diff (unstaged): !`git diff -- '*.ts' '*.tsx' '*.js' '*.jsx' | head -500 || true`

## Execution Steps

### 1. File Analysis

Read each target file and understand:
- All exported functions, components, hooks, utilities
- Input parameters and their types
- Return values and output shapes
- Side effects (metrics, analytics, API calls, state mutations)
- Edge cases and error conditions
- Dependencies and imports

### 2. Test Discovery

Search for existing tests:
- Check `__tests__/` directories adjacent to file
- Check `*.test.ts`, `*.test.tsx`, `*.spec.ts`, `*.spec.tsx` patterns
- Check project test directory structure (e.g., `tests/`, `spec/`)
- Identify the test framework in use (Jest, Vitest, React Testing Library, etc.)

### 3. Coverage Analysis

If tests exist:
- Map existing test cases to source code functions/branches
- Identify untested code paths, branches, and edge cases
- Note any tested functionality that could use improvement
- Prepare suggestions for improving existing tests (DO NOT auto-apply)

If no tests exist:
- Proceed directly to writing comprehensive tests

### 4. Test Writing

Write tests following these principles:

#### Test Structure

- Use descriptive `describe` blocks that mirror the module structure
- Use `it` statements that read as complete sentences describing behavior
- Group related assertions in single tests for completeness
- Separate tests ONLY for distinct side effects (metrics, analytics, logging)

#### Test Helpers (REQUIRED for components)

Create render helpers for any component tests:

```typescript
function renderComponentName(props: Partial<ComponentNameProps> = {}) {
  const defaultProps: ComponentNameProps = {
    // sensible defaults that represent typical usage
  };
  return render(<ComponentName {...defaultProps} {...props} />);
}
```

#### Completeness Over Quantity

```typescript
// CORRECT: One test asserting all outputs
it('returns correctly formatted user data', () => {
  const result = formatUserData(input);

  expect(result.id).toBe('123');
  expect(result.displayName).toBe('John Doe');
  expect(result.email).toBe('john@example.com');
  expect(result.isActive).toBe(true);
  expect(result.createdAt).toBeInstanceOf(Date);
});

// INCORRECT: Five separate tests for each property
```

#### Side Effects Get Separate Tests

```typescript
describe('submitForm', () => {
  it('submits data and returns success response', () => {
    // test the core behavior
  });

  it('emits form_submitted metric on success', () => {
    // test the metric side effect
  });

  it('emits form_error metric on failure', () => {
    // test error metric separately
  });
});
```

### 5. Prohibited Patterns

NEVER use:
- `jest.clearAllMocks()`
- `jest.resetAllMocks()`
- `beforeEach(() => jest.clearAllMocks())`
- Any variant of clearing/resetting all mocks globally

Instead:
- Use `jest.fn()` fresh in each test where needed
- Use `mockImplementation` or `mockReturnValue` per-test
- Let each test be self-contained

### 6. Code Quality

After writing tests:
- Run the project's lint command to identify errors
- Fix any linting issues in the generated test code
- Ensure imports are correctly ordered per project config
- Verify TypeScript types are correct and complete

### 7. Output Format

For NEW tests:
- Write the complete test file
- Include all necessary imports
- Add test helpers at the top of describe blocks

For EXISTING tests with gaps:
- Show the new test cases to add
- Indicate where they should be inserted
- Maintain existing file structure and patterns

For EXISTING tests with suggestions:
- List suggestions clearly with rationale
- DO NOT automatically apply these changes
- Let the user decide which suggestions to adopt

## Testing Philosophy

- Tests document expected behavior for future developers
- A reader should understand what the code does by reading tests alone
- Avoid testing implementation details; test observable behavior
- Mock at system boundaries (network, storage), not internal modules
- Prefer real implementations over mocks when practical
- Test the contract, not the internals

## Readability Standards

- Variable names should be self-documenting
- Avoid magic values; use named constants with clear intent
- Setup code should be obvious; avoid hidden state
- Each test should tell a story: given X, when Y, then Z
- Comments only for genuinely complex setup that can't be simplified

## Context

Assume expert frontend developer context. Skip basic explanations. Focus on:
- Accurate coverage analysis
- High-quality, maintainable test code
- Practical suggestions backed by reasoning
