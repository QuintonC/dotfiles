---
name: pls-explain
description: Provide deep technical explanations of code at the file, method, or line level, covering implementation details, design patterns, and system interactions. Use when the user asks to explain, break down, or deep-dive into code, or mentions "pls explain".
---

# Deep Code Explainer

Provide comprehensive technical explanations of code, diving deep into implementation details, design patterns, and system interactions.

## Target selection

The target is a file path or a file:line reference. Examples:

- `app/models/user.rb` — explain the entire file
- `app/models/user.rb:42` — explain a specific line/method
- `lib/auth/jwt.rb:15-30` — explain a line range

## What it does

1. Read the target file and surrounding context.
2. Analyze dependencies and related files.
3. Trace execution flow and data transformations.
4. Identify patterns, algorithms, and architectural decisions.
5. Explain technical implications and trade-offs.

## Analysis Depth

### Code Structure

- Class/module hierarchy and inheritance chain.
- Method signatures and parameter handling.
- Return values and side effects.
- Exception handling and error flows.
- Memory management and performance implications.

### Technical Details

- Algorithm complexity (time/space).
- Data structure choices and implications.
- Concurrency/threading considerations.
- Database queries and N+1 problems.
- Network calls and API interactions.

### System Context

- Dependencies and coupling.
- Design patterns employed.
- Framework-specific magic/conventions.
- Metaprogramming and dynamic behavior.
- Security implications.

### Runtime Behavior

- Execution order and control flow.
- State mutations and transformations.
- Callback chains and hooks.
- Event propagation.
- Resource lifecycle.

## Explanation Format

- **Overview**: high-level purpose and responsibility.
- **Line-by-line breakdown**: what each line/block does, why it's implemented this way, alternatives considered, performance/security implications.
- **Data flow**: input sources and validation, transformation pipeline, output destinations, error propagation paths.
- **Integration points**: external dependencies, database interactions, cache usage, queue/job processing, API calls.
- **Gotchas & edge cases**: non-obvious behavior, framework magic, hidden assumptions, potential bugs or race conditions, upgrade/migration concerns.

## Special Focus Areas

### For Ruby/Rails Code

- Metaprogramming techniques.
- ActiveRecord callbacks and associations.
- Middleware and Rack integration.
- Lazy loading and eager loading.
- Module mixins and concerns.

### For Complex Logic

- State machines.
- Recursive algorithms.
- Concurrent operations.
- Transaction boundaries.
- Distributed system concerns.

### For Performance-Critical Code

- Query optimization.
- Caching strategies.
- Memory allocation.
- Background job design.
- Rate limiting.

## Output Examples

For a line like `User.includes(:posts).where(active: true).find_each`:

- Explain the eager-loading strategy.
- Detail batch processing with `find_each`.
- Memory implications of `includes` vs `joins`.
- Query execution plan.
- N+1 prevention technique.
- When this approach fails.

For a method using metaprogramming:

- How `define_method` works.
- Method resolution order.
- Performance vs flexibility trade-offs.
- Debugging challenges.
- Testing considerations.

## Requirements

- Read the file and surrounding context.
- Trace through related files.
- Identify framework/library-specific behavior.
- Explain both what and why.
- Highlight non-obvious implications.

## Notes

- Technical depth over surface-level description.
- Assume the reader has programming knowledge.
- Include performance and security considerations.
- Reference documentation when relevant.
- Explain historical context if apparent.
