---
name: adhd-mode
description: Toggle ADHD-friendly output on or off for the rest of this session. Invoke with /skill:adhd-mode off to disable, /skill:adhd-mode on to re-enable. Manual only.
disable-model-invocation: true
metadata:
  style_source: https://github.com/ayghri/i-have-adhd
  note: Toggles the ADHD output style defined in ~/.agents/references/adhd_output.md, which is adapted from ayghri's i-have-adhd skill.
---

# adhd-mode

Session toggle for the ADHD-friendly output style defined in `~/.agents/references/adhd_output.md`.

The argument after the command sets the mode. Read it and apply the matching branch. The instruction persists for the rest of this session (it lives in the transcript). If invoked again later, the newest invocation wins.

## If the argument is `off` (or `stop`, `disable`, `normal`)

ADHD output style is now OFF for the remainder of this session.

- Ignore `~/.agents/references/adhd_output.md` and the ADHD summary in the Communication section of AGENTS.md / CLAUDE.MD.
- Respond in normal prose: preambles, recaps, and closers are allowed again; brevity is no longer enforced beyond the general "be concise" guidance.
- Keep the rest of the working agreement (writing principles, workflow, git rules) unchanged.

Confirm in one line: "ADHD mode off for this session." Then continue with whatever the user asked.

## If the argument is `on` (or `start`, `enable`)

ADHD output style is now ON for the remainder of this session (this is also the default).

- Read `~/.agents/references/adhd_output.md` and apply it every turn from now on.
- Lead with the next action, number multi-step work, restate state, suppress tangents, no preamble or closers.

Confirm in one line: "ADHD mode on." Then continue.

## If there is no argument or it is unclear

State the current default (ON) and show the two commands:

```
/skill:adhd-mode off
/skill:adhd-mode on
```

Ask which one the user wants. Do not change anything until told.
