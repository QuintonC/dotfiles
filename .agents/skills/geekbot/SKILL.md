---
name: geekbot
description: Prepare a raw markdown Geekbot standup message by synthesizing daily notes, calendar, Slack, and GitHub activity, and log it to the weekly activity archive. Use when the user asks to prepare their standup, write a Geekbot update, or mentions "geekbot".
---

# Geekbot Standup

Prepare a raw markdown message the user can paste into their Geekbot standup in Slack. This standup runs at the **end of the day** (4pm local).

## Context

Run these bash commands (via the `bash` tool) to determine the relevant dates:

- Day of week: `date +%u`
- Today: `date "+%Y-%m-%d"`
- Yesterday: `date -d "-1 day" "+%Y-%m-%d" 2>/dev/null || date -v-1d "+%Y-%m-%d"`
- Tomorrow: `date -d "+1 day" "+%Y-%m-%d" 2>/dev/null || date -v+1d "+%Y-%m-%d"`
- Three days ago: `date -d "-3 days" "+%Y-%m-%d" 2>/dev/null || date -v-3d "+%Y-%m-%d"`
- Day name today: `date +%A`
- Next workday: `date -d "+1 day" +%A 2>/dev/null || date -v+1d +%A`

Based on the day-of-week number:

- If day = 1 (Monday): the previous standup file is in the **previous week's folder** at `5.md` (Friday).
- If day = 2-5 (Tue-Fri): the previous standup file is `{day - 1}.md` in the **current week's folder**.
- If day = 5 (Friday): "What will you do tomorrow?" becomes "What will you do Monday?".

The day-of-week number tells us what day today is (1=Mon through 5=Fri). Today's date is used for gathering today's work. The previous standup file tells us what was planned (via its "What will you do tomorrow?" section).

## Overarching goal

Prepare a raw markdown message for the `{team_standup_name}` Geekbot standup in Slack:

- Read today's daily note at `~/quintonc/engram/daily/{yyyy-mm-dd}.md` (e.g., `2026-04-17.md`) if it exists.
  - This is the running journal for the day — meetings prepped for, work noted, decisions made, and personal `// ` comments.
  - Weight it heavily for "What did you do today?".
  - Treat it as one source among several — the daily note does NOT capture in-flight GitHub PR/issue activity or Slack threads.
  - Always cross-reference with calendar, Slack, and GitHub for the complete picture.
- Look at the previous standup entry stored in `~/quintonc/activity/yyyy-ww/{previous_day_number}.md`.
  - **IMPORTANT**: On Monday, the previous standup file is in the **previous week's folder** (e.g., if today is week 13, look in the week 12 folder for `5.md`).
  - If no files exist in the activity directory, fall back to using `slack-mcp` to find previous interactions with the Geekbot application in Slack.
  - If the user didn't respond the previous day, reference the last time they responded to the Geekbot survey.
  - Check the previous standup's **"What will you do tomorrow?"** section to verify follow-through on planned work.
- Use `gworkspace-mcp` to get calendar events for today and tomorrow.
  - Avoid referencing common events such as Lunch, Focus time, or anything marked Personal. Focus on project meetings and one-on-ones.
  - For today's events (to populate "What did you do today?"): `time_min: "today"`, `time_max: "tomorrow"`, `max_results: 20`.
  - For tomorrow's events (to inform "What will you do tomorrow?"): `time_min: "tomorrow"`, `time_max: "day after tomorrow"`, `max_results: 20`.
- If an issue linked in the previous "What will you do tomorrow?" wasn't closed (through a linked PR), check:
  - Is the linked PR waiting for reviewers?
  - Is this PR approved but not yet shipped (via the Graphite merge queue or `/shipit`)?
  - Is there a linked PR?
- From there, ask clarifying questions about the status of the work. The user may not have gotten to it, so capture any disruptions to that flow.
  - If a PR is mentioned directly, run through the same checks.
  - Prompt for more information on unclear items. For example:
    > You mentioned you were going to investigate an action item from {incident_channel} with @{colleague}. Were you able to resolve the issue?

## Accuracy requirements

- Focus on actual work completed, not speculation.
- Only include activities that actually happened based on evidence.
- Do not invent or assume activities (like "ATC rotation" or "reviewing PRs"); reference only events returned from `gworkspace-mcp`.
- If unsure about something, omit it rather than guess.
- Match activities to what was said in the previous standup.
- **Meetings ALWAYS go under the "General" section**, never under project-specific sections.
- Do not include activities the user didn't actively participate in (e.g., threads only observed but not contributed to).
- Never drop links when referencing items. Always preserve link references when moving or editing text.

## Slack handles

- When mentioning people by name, use their Slack handle.
- Use the Vault MCP (`vault_search_users` and `vault_get_user`) to look up the correct Slack handle for each person.
- Do not guess handles from Slack messages — always verify via Vault.

## User-provided context

- When the user provides links during clarifying questions (docs URLs, Slack threads), include those links in the final output.
- Use markdown link format: `[descriptive text](URL)`.
- This includes internal documentation links, Slack thread permalinks, and any other references shared.

## Formatting preferences

- Avoid emdashes (—) in the output.
- If additional context is needed for a line item, use sub-items instead. For example:
  - Instead of: `Bundle + Deploy Review with @{colleague} — decided to use staging as test candidate`
  - Use:
    ```md
    - Bundle + Deploy Review with @{colleague}
      - Decided to use staging as test candidate
    ```

## Link handling

- **IMPORTANT**: All links must use markdown link format: `[descriptive text](URL)`.
- For GitHub links, use the PR/issue title as the link text: `[PR title text](github.com/...)`.
- If there are GitHub links, pull the info from the PR or issue using the `gh` CLI. Use the PR/issue title as the link text.
  - For Graphite links, extract the `repository` and `organization` from the link and use `gh` as instructed above.
    - Graphite link format: `https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number}`.
- For example: "Shipped fix to [prevent duplicate email checks](https://github.com/{organization}/{repository}/pull/{pull_request_number})".

## Slack activity

- Search Slack for the user's activity from the previous standup through now.
- **IMPORTANT**: Use `my_messages` with `after:{yesterday} before:{tomorrow}` to ensure full coverage of any late-day activity from after the previous standup.
- **IMPORTANT**: When searching Slack, explicitly specify date ranges with the current year.
  - Edge case: for the first report of the new year, refer to the most recent activity since the last update in Slack.
- Summarize updates to at most 3 bullet points per channel. Format with the channel name as the first-level list item and sub-items as the second level:

  ```md
  - #proj-{project_channel}
    - Activity summary 1
    - Activity summary 2
    - Activity summary 3
  ```

## Tidiness

- Use the proper tools. You should have access to `slack-mcp` and the `gh` CLI.
- If nothing is blocking progress, provide a `-` as the response to that question.

## Wrapping up the response

**Do not** submit the message. Structure the response according to the three Geekbot prompts:

1. What did you do today?
2. What will you do tomorrow?
3. Anything blocking your progress?

**Always provide the final standup in a markdown code block** using the three headers above.

### Section guidance

- **"What did you do today?"**: all work completed today. Since this runs at end of day, this captures the full day's work with no ambiguity.
- **"What will you do tomorrow?"**: forward-looking planned work for the next workday. On Friday, change the header to "What will you do Monday?".
- **Meetings**: always list under the "General" section, not under project-specific sections.

### Expected outcome example

```md
## What did you do today?

- #proj-{project_channel}
  - Shipped [PR title](https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number})
  - Opened fix to [issue description](https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number})
  - Participated in [#help-dev-platform thread on topic](https://shopify.slack.com/archives/{channel_id}/{message_ts})
    - Key outcome or decision from the thread
- #proj-{another_channel}
  - Paired with @{colleague} on feature work
  - Found root cause of issue and opened [fix PR title](https://github.com/{organization}/{repository}/pull/{pull_request_number})
- General
  - Project sync meeting
  - 1-1 with @{colleague}
    - Paired on topic
  - Backlog grooming

## What will you do tomorrow?

- #proj-{project_channel}
  - Ship [PR title](https://github.com/{organization}/{repository}/pull/{pull_request_number}) once CI is green
  - Continue work on [issue title](https://github.com/{organization}/{repository}/issues/{issue_number})

## Anything blocking your progress?

-
```

## Final output format

**CRITICAL**: Always provide the final standup message in a raw markdown code block using triple backticks (```md). This ensures the user can copy and paste directly into Geekbot without formatting issues.

## Side effects

These reports also build context for impact reviews. Create a new folder for the first report of each week (which may fall on any day given holidays and vacation):

1. For the first report of each week, ensure a folder exists at `~/quintonc/activity/yyyy-ww` matching the year and week number, `yyyy-ww`.
   - Week numbers use ISO 8601 week numbering (`%V`), NOT `%U` or `%W`.
   - **ALWAYS** verify the ISO week number by running `date -d "{target_date}" "+%Y-%V" 2>/dev/null || date -j -f "%Y-%m-%d" "{target_date}" "+%Y-%V"` before creating folders or saving files. Never assume the week number from existing folder names.
2. Put together a markdown file, `{day_of_week}.md`, with the **final** standup response.
   - **IMPORTANT**: The standup content may be iterated on. Only capture the final output. The user will indicate when the information is complete and should be logged into the weekly directory.
3. If a file is missing for the previous day, let the user know so it can be created from prior history.
4. At the start of the following week, put together a `summary.md` for the prior week, including only:
   - Highlights from the prior week from the user's own contributions.
   - Summarized information for projects contributed to or championed (use the Vault MCP, `vault-mcp`, for this information).

## Iterations and corrections

- If the user requests changes, maintain the same raw markdown code block format for all iterations.
- Provide each revised version in a new markdown code block.
- Track requested changes to avoid repeating the same issues.
