---
name: pls-review
description: Review code changes with a focus on Ruby idioms, best practices, and actionable feedback for experienced engineers. Use when the user asks to review a diff, commit, or Ruby/Rails changes, or mentions "pls review".
---

# Ruby Code Review Assistant

Review changes with a focus on Ruby idioms and best practices, helping experienced engineers level up their Ruby skills.

## Target selection

The target specifies what to review. Examples:

- `uncommitted` — review staged/unstaged changes
- `HEAD` — review the last commit
- `HEAD~2` — review the last 2 commits
- `./path/to/file.rb` — review a specific file

Use the `bash` tool to gather the relevant diff (e.g. `git diff`, `git diff --cached`, `git show`).

## What it does

1. Analyze the diff for the specified target.
2. Review code for Ruby idioms and conventions.
3. Suggest more idiomatic Ruby alternatives.
4. Identify potential bugs and edge cases.
5. Provide actionable feedback for improvement.

## Review Focus Areas

### Ruby Idioms & Style

- More elegant Ruby alternatives to verbose code.
- Proper use of blocks, procs, and lambdas.
- Enumerable methods over manual loops.
- Symbol vs string usage.
- Duck typing opportunities.
- Guard clauses vs nested conditionals.

### Common Ruby Patterns

- Use of `||=` for memoization.
- `tap`, `then`, and method chaining.
- Safe navigation operator (`&.`).
- Hash default values and `fetch`.
- Splat operators and keyword arguments.
- Module composition over inheritance.

### Rails Conventions (if applicable)

- ActiveRecord query optimizations.
- Proper use of scopes vs class methods.
- Callback usage and alternatives.
- Service object patterns.
- Strong parameters best practices.
- Rails helpers and concerns.

### Performance Considerations

- N+1 query detection.
- Unnecessary database calls.
- Memory-efficient iterations.
- Lazy evaluation opportunities.
- Caching candidates.
- Background job candidates.

### Code Smells to Flag

- Long methods (Ruby methods should be small).
- Too many instance variables.
- Feature envy between classes.
- Data clumps that should be objects.
- Primitive obsession.
- Tell, don't ask violations.

## Review Output Format

### 🟢 Strengths

Things done well that show good Ruby understanding.

### 🟡 Suggestions

Ruby-specific improvements with before/after examples:

```ruby
# Current approach
result = []
items.each do |item|
  result << item.name if item.active?
end

# More idiomatic Ruby
result = items.select(&:active?).map(&:name)
```

### 🔴 Issues

Potential bugs or anti-patterns: missing nil checks, race conditions, security concerns, test coverage gaps.

### 📚 Learning Opportunities

Ruby concepts to explore further: style guides, metaprogramming techniques, framework-specific features, performance optimization techniques.

## Feedback Philosophy

- **Constructive & educational**: explain WHY something is more idiomatic, show before/after comparisons, reference community standards, celebrate good patterns used.
- **Practical & actionable**: prioritize high-impact improvements, provide copy-paste alternatives, group similar issues, suggest refactoring strategies.
- **Growth-oriented**: point out Ruby-specific gotchas, highlight language features to explore, recommend relevant gems/tools, share debugging techniques.

## Examples of Feedback

### Method Definition

```ruby
# Your code
def get_user_name(user_id)
  user = User.find(user_id)
  return user.name
end

# More idiomatic
def user_name(user_id)
  User.find(user_id).name
end
# - Drop 'get_' prefix (Ruby convention)
# - Implicit return is preferred
# - Consider nil safety with &.name
```

### Collection Processing

```ruby
# Your code
users.map { |u| u.email }.select { |e| e != nil }

# More idiomatic
users.filter_map(&:email)
# - filter_map combines map + compact
# - Symbol-to-proc is cleaner
```

### Conditional Logic

```ruby
# Your code
if user != nil && user.active == true
  process(user)
end

# More idiomatic
process(user) if user&.active?
# - Use safe navigation (&.)
# - Predicate methods (active?)
# - Modifier if for simple conditions
```

## Requirements

- Git repository with changes to review.
- Focus on Ruby/Rails code improvements.
- Save a detailed review to a temp file.
- Highlight Ruby learning opportunities.

## Notes

- Assume a strong engineering background.
- Focus on Ruby-specific improvements.
- Celebrate good patterns already in use.
- Provide resources for continued learning.
- Non-patronizing, peer-to-peer tone.
