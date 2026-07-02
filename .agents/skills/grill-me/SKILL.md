---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when the user wants to stress-test a plan, get grilled on their design, validate an approach before building, or mentions "grill me".
---

# Grill Me

Interview the user relentlessly about every aspect of their plan until you reach a shared understanding.

## How to run it

- Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.
- Ask one focused question at a time rather than dumping a list — let each answer shape the next question.
- For each question, provide your own recommended answer along with the reasoning behind it.
- If a question can be answered by exploring the codebase, explore the codebase instead of asking.
- Surface hidden assumptions, edge cases, failure modes, and unresolved dependencies as you go.
- Stop when every branch of the decision tree is resolved and you and the user share the same mental model.

## Notes

- This is a thinking/alignment exercise — do not start implementing until the design is fully resolved, unless explicitly asked.
- Any arguments passed after the command are the plan or topic to grill; if none are given, ask the user what they want to be grilled on.
