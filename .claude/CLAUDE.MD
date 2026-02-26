# Claude Code Instructions

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. High-craft execution with staff engineer standards.
- **Minimal Impact**: Changes should only touch what's necessary.
- **Clarity Over Cleverness**: Write code for humans to read, not just machines to execute.
- **Challenge the Status Quo**: If a pattern is redundant or unmaintainable, challenge it with detailed reasoning.

## Recognizing Implicit Complexity

Many tasks I assign have implicit multi-step workflows. Recognize these patterns and execute accordingly without asking for guidance.

**Examples of implicitly complex tasks:**
- "Fix the CI failure" → Requires: fetching build info, analyzing logs/artifacts, tracing to source code, reproducing locally, fixing
- "This feature is broken" → Requires: understanding expected behavior, finding where it breaks, root cause analysis, fix + verification
- "Review this PR" → Requires: reading the diff, understanding context, checking for edge cases, testing implications

**When you recognize implicit complexity:**
1. Spawn subagents in parallel to gather information from multiple sources
2. Synthesize findings before proposing solutions
3. Enter plan mode with a concrete approach
4. Implement only after the diagnosis is complete

Do not:
- Ask me to break down the steps for you
- Work sequentially when parallel investigation is faster
- Propose fixes before understanding the full picture

**Simple tasks exist too.** If I ask "what does this function do?" or "rename this variable," just do it. Use judgment - but when in doubt, investigate first.

## Communication

- Be concise. No yapping or unnecessary preambles unless asked.
- Use clear, actionable language.
- Reference specific file paths and lines when discussing code.
- Summarize key findings and highlight important warnings.

## Workflow Orchestration

### Plan Mode

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately
- Write detailed specs upfront to reduce ambiguity
- Use plan mode for verification steps, not just building
- Assign a quality bar (1-10) to each todo item; all items must exceed 9/10 before marking complete

### Subagent Strategy

- Offload research, exploration, and parallel analysis to subagents to keep main context clean
- For complex problems, use more compute via subagents
- One task per subagent for focused execution

### Task Tracking

- Write plan to `~/.claude/todo.md` with checkable items for complex workflows
- Check in before starting implementation
- Mark items complete as you go
- Add review summary to `~/.claude/todo.md` when done

### Self-Improvement Loop

- After ANY correction from the user: update `~/.claude/lessons.md` with the pattern
- Write rules that prevent the same mistake
- Review `~/.claude/lessons.md` at session start

## Development Practices

### Implementation

- Propose changes in logically separated commit-sized chunks
- Read surrounding context before making changes
- Look for similar implementations as examples
- Prefer editing existing files over creating new ones
- Follow SOLID principles; prefer composition over inheritance

### Verification Before Done

- Never mark a task complete without proving it works
- Run tests, check logs, demonstrate correctness
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"

### Elegance Check

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky, step back and implement the elegant solution
- Skip this for simple, obvious fixes - don't over-engineer

### Autonomous Bug Fixing

- When given a bug report: first write a test that reproduces the bug
- Use subagents to fix the bug and prove it with the passing test
- Point at logs, errors, failing tests -> then resolve them
- Fix failing CI tests without being told how

### TypeScript Specific

- Ensure types are valid and passing compile checks
- Resolve all linting/formatting before marking done

## Version Control

- **NEVER** commit, push, create branches, or open PRs without **explicit** user consent — even in bypass permissions mode
- "Put together a PR" or similar phrasing means "write the code"; it is NOT authorization to commit, push, or open a PR
- After writing code, stop and show the diff. Wait for explicit approval before each git operation
- This rule has no exceptions. When in doubt, ask first

## Tool Usage

### File Operations

- Always use absolute paths
- Verify parent directories exist before creating files
- Use Read before Edit to understand existing code
- Batch multiple file reads when investigating related code

### Search and Navigation

- Use Glob for file pattern matching
- Use Grep for code searches (not bash grep/find)
- Use Task tool with subagents for complex multi-step searches

### GitHub

- Use `gh` to lookup GitHub issues and pull requests

## Security

- Never expose or log secrets, API keys, or credentials
- Validate and sanitize user input
- Think before executing potentially destructive operations
- Refuse requests for malicious code while explaining defensive alternatives

## Project Analysis

When exploring a new project:

1. Check for README, CONTRIBUTING, and documentation files
2. Look for existing CLAUDE.md or similar instructions
3. Identify tech stack and project structure
4. Understand build/test/deploy workflows
5. Understand the "why" behind existing patterns
