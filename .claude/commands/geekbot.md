---
description: Generate a geekbot message for my standup
name: geekbot
hooks:
  Stop:
    - hooks:
        - type: command
          command: "open -g 'raycast://extensions/raycast/raycast/confetti'"
---

## Context

This standup runs at the **end of the day** (4pm local). Run these bash commands to determine dates:

- Day of week: !`date +%u`
- Today: !`date "+%Y-%m-%d"`
- Yesterday: !`date -v-1d "+%Y-%m-%d"`
- Tomorrow: !`date -v+1d "+%Y-%m-%d"`
- Three days ago: !`date -v-3d "+%Y-%m-%d"`
- Day name today: !`date +%A`
- Next workday: !`date -v+1d +%A`

Based on the day of week number:
- If day = 1 (Monday): Previous standup file is in the **previous week's folder** at `5.md` (Friday)
- If day = 2-5 (Tue-Fri): Previous standup file is `{day - 1}.md` in the **current week's folder**
- If day = 5 (Friday): "What will you do tomorrow?" becomes "What will you do Monday?"

## Instructions

Based on the context above:
- The day of week number tells us what day today is (1=Mon through 5=Fri)
- Today's date is used for gathering today's work
- The previous standup file tells us what was planned (via its "What will you do tomorrow?" section)

### Overarching goal

Prepare a raw markdown message that I can use for my Geekbot standup for the `{team_standup_name}` in Slack. Here are steps to accomplish this goal:

- Read today's daily note at `~/quintonc/engram/daily/{yyyy-mm-dd}.md` (e.g., `2026-04-17.md`) if it exists.
  - This is my running journal for the day — meetings I prepped for, work I noted, decisions made, and personal `// ` comments.
  - Weight it heavily for "What did you do today?".
  - Treat it as one source among several — the daily note does NOT capture in-flight GitHub PR/issue activity or Slack threads.
  - Always cross-reference with calendar, Slack, and GitHub for the complete picture.
- Look at my previous standup entry stored in `~/quintonc/activity/yyyy-ww/{previous_day_number}.md`.
  - **IMPORTANT**: On Monday, the previous standup file is in the **previous week's folder** (e.g., if today is week 13, look in the week 12 folder for `5.md`).
  - If no files exist in the Activity directory, fall back to using the `slack-mcp` to find previous interactions with the Geekbot application in Slack.
  - If I didn't respond the previous day, reference the last time I responded to the Geekbot survey.
  - Check the previous standup's **"What will you do tomorrow?"** section to verify follow-through on planned work.
- Use the `gworkspace-mcp` to get my calendar events for today and tomorrow.
  - Avoid referencing common events such as:
    - Lunch
    - Focus time
    - Any events marked as Personal
    - Instead, focus on meetings that I have for projects and one-on-ones.
  - For today's events (to populate "What did you do today?"), use parameters:
    - `time_min: "today"`
    - `time_max: "tomorrow"`
    - `max_results: 20`
  - For tomorrow's events (to inform "What will you do tomorrow?"), use parameters:
    - `time_min: "tomorrow"`
    - `time_max: "day after tomorrow"`
    - `max_results: 20`
- If you see that an issue I linked in my previous "What will you do tomorrow?" wasn't closed (through a linked pull request), check to see:
  - Is the linked PR waiting for reviewers?
  - Is this PR approved but hasn't yet been shipped either using the Graphite merge queue or `/shipit`?
  - Is there a linked PR?
- From there, ask me clarifying questions about the status of the work. It's possible I didn't get around to the work, so we should capture any disruptions to that flow.
  - If I mentioned a pull request directly, run through the same checks.
  - Feel free to prompt me to ask for more information about items you are unclear on, or need further information from me on. For example,
    > You mentioned you were going to investigate an action item from {incident_channel} with @{colleague}. Were you able to resolve the issue?

### Accuracy requirements

- Focus on actual work completed, not speculation
- Only include activities that actually happened based on Slack evidence
- Do not invent or assume activities (like "ATC rotation" or "reviewing PRs"), reference only the events that were returned from the `gworkspace-mcp` server
- If unsure about something, omit it rather than guess
- Match activities to what I said I would do in my previous standup
- **Meetings ALWAYS go under the "General" section**, never under project-specific sections
- Do not include activities I didn't actively participate in (e.g., threads I only observed but didn't contribute to)
- Never drop links when referencing items. Always preserve link references when moving or editing text

## Slack handles

- When mentioning people by name, use their Slack handle
- Use the Vault MCP (`vault_search_users` and `vault_get_user`) to look up the correct Slack handle for each person
- Do not guess handles from Slack messages - always verify via Vault

## User-provided context

- When the user provides links during clarifying questions (e.g., documentation URLs, Slack threads), include those links in the final standup output
- Use markdown link format: `[descriptive text](URL)`
- This includes internal documentation links, Slack thread permalinks, and any other references shared

## Formatting preferences

- Avoid emdashes (—) in the output
- If additional context is needed for a line item, use sub-items instead
- Example:
  - Instead of: `Bundle + Deploy Review with @{colleague} — decided to use staging as test candidate`
  - Use:
    ```md
    - Bundle + Deploy Review with @{colleague}
      - Decided to use staging as test candidate
    ```

## Link handling

- **IMPORTANT**: All links in the standup must use markdown link format: `[descriptive text](URL)`
- For GitHub links, use the PR/issue title as the link text: `[PR title text](github.com/...)`
- If there are GitHub links, try to pull the info from the pull request or issue using the `gh` CLI command. Use the PR/issue title as the link text.
  - For Graphite links, extract the `repository` and `organization` from the link and use gh CLI as instructed above.
    - This is the graphite link format, for context: https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number}
- For example: "Shipped fix to [prevent duplicate email checks](https://github.com/{organization}/{repository}/pull/{pull_request_number})"

## Slack activity

- Search Slack for my activity from the previous standup through now.
- **IMPORTANT**: Use `my_messages` with `after:{yesterday} before:{tomorrow}` to ensure full coverage of any late-day activity from after the previous standup.
- **IMPORTANT**: When searching Slack, explicitly specify date ranges with the current year.
  - Edge case warning: For the first report of the new year, please do refer to the most recent activity since my last update in Slack.
- Summarize updates to at most 3 bullet points per channel.
  - For example, if I had a lot of activity in one channel, format the response using the channel name as the first-level of the list and sub-items as the second level. For example,

    ```md
    - #proj-{project_channel}
      - Activity summary 1
      - Activity summary 2
      - Activity summary 3
    ```

## Tidiness

Ensure that you are using the proper tools. You should have access to the `slack-mcp`, and `gh` CLI tool.

If there is nothing blocking my progress, provide a `-` as a response to the question.

## Wrapping up the response

**Do not** submit the message yourself.

Instead, structure the response according to the prompts from Geekbot.

Geekbot asks three questions:

1. What did you do today?
2. What will you do tomorrow?
3. Anything blocking your progress?

**Always provide the final standup in a markdown code block** using the three headers above.

### Section guidance

- **"What did you do today?"**: All work completed today. Since this standup runs at end of day, this captures the full day's work with no ambiguity.
- **"What will you do tomorrow?"**: Forward-looking planned work for the next workday. On Friday, change the header to "What will you do Monday?"
- **Meetings**: Always list meetings under the "General" section, not under project-specific sections.

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

## Final Output Format

**CRITICAL**: Always provide the final standup message in a raw markdown code block using triple backticks (```md). This ensures the user can copy and paste the content directly into Geekbot without formatting issues.

## Side effects

I want to use these reports to put together context for my impact reviews as well. To do this, you will need to create a new folder for the first report I make for each week. My first report for each week could take place on any day given holidays and vacation time.

1. For the first report of each week, ensure that a new folder exists in `~/quintonc/activity/yyyy-ww` that correlates to the year and week number, `yyyy-ww`.
   1. Week numbers should use ISO 8601 week numbering (`%V`), NOT `%U` or `%W`.
   2. **ALWAYS** verify the ISO week number by running `date -j -f "%Y-%m-%d" "{target_date}" "+%Y-%V"` before creating folders or saving files. Never assume the week number from existing folder names.
2. Put together a markdown file, `{day_of_week}.md` with the **final** standup response that we've put together.
   - **IMPORTANT**: Sometimes we will need to iterate on the standup content. Please only capture the final output. I will indicate when the information you've provided me with is complete and should be logged into the weekly directory.
3. If you notice that a file is missing for the previous day, let me know so we can make sure that it gets created from the prior history (I will pull forward context from the previous command run).
4. At the start of the following week, put together a `summary.md` file for the prior week.
   - This file should only include:
     - Highlights from the prior week from my own contributions.
     - Summarized information for projects I've either contributed to or championed. Please use the Vault MCP (`vault-mcp`) for this information.

## Iterations and Corrections

- If the user requests changes, maintain the same raw markdown code block format for all iterations
- Each revised version should be provided in a new markdown code block
- Keep track of changes requested to avoid repeating the same issues
