---
allowed-tools:
  - Bash(date*)
  - Bash(gh search prs --author=@me *)
  - Bash(gh pr view *)
  - Bash(gh pr list *)
  - Bash(gh issue view *)
  - Bash(mkdir *)
  - Glob
  - mcp__slack-mcp__get_messages
  - mcp__gworkspace-mcp__calendar_events
  - Read(/Users/quintonchester/Activity/**)
  - Write(/Users/quintonchester/Activity/**)
description: Generate a geekbot message for my standup
model: claude-opus-4-5
name: geekbot
---

## Context

Run these bash commands to determine the current day and previous workday:

- Day of week: !`date +%u`
- Today: !`date "+%Y-%m-%d"`
- Yesterday: !`date -v-1d "+%Y-%m-%d"`
- Three days ago: !`date -v-3d "+%Y-%m-%d"`
- Day name today: !`date +%A`
- Day name yesterday: !`date -v-1d +%A`

Based on the day of week number from the first command:
- If day = 1 (Monday): Use "Three days ago" as previous workday, previous day number is 5, reference as "Friday", and look in the **previous week's folder** (week - 1)
- If day = 2-5 (Tue-Fri): Use "Yesterday" as previous workday, previous day number is (day - 1), reference as "yesterday", and look in the **current week's folder**

## Instructions

Based on the context above:
- The day of week number tells us what day today is (1=Mon through 5=Fri)
- Today's date is shown in YYYY-MM-DD format
- Previous workday is the date we need to look back to
- Previous day number is the file we need to check (1.md through 5.md)
- Previous day name is how we reference it ("yesterday" or "Friday")

### Overarching goal

Prepare a raw markdown message that I can use for my Geekbot standup for the `{team_standup_name}` in Slack. Here are steps to accomplish this goal:

- Look at my previous message from {previous_day_name}'s Geekbot submission using the files we created from the previous standup entry stored in `/Users/quintonchester/Activity/yyyy-ww/{previous_day_number}.md`.
  - **IMPORTANT**: On Monday, the previous standup file is in the **previous week's folder** (e.g., if today is week 3, look in `2026-02/5.md` for Friday's standup).
  - If no files exist in the Activity directory, fall back to using the `slack-mcp` to find previous interactions with the Geekbot application in Slack.
  - If I didn't respond to the previous day, please reference the last time I responded to the Geekbot survey.
- Use the `gworkspace-mcp` to get my calendar events for today and the previous workday.
  - Avoid referencing common events such as:
    - Lunch
    - Focus time
    - Any events marked as Personal
    - Instead, focus on meetings that I have for projects and one-on-ones.
  - For today's events, use parameters:
    - `time_min: "today"`
    - `time_max: "tomorrow"`
    - `max_results: 20`
  - For previous workday's events (to populate "What have you done"), query with the previous workday's date range.
- If you see that an issue I linked in my previous "What will you do today" wasn't closed (through a linked pull request), check to see:
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
    - For example, https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number} would be a pull request in the `{organization}` organization, `{repository}` repository, and pull request number `{pull_request_number}`.
- For example: "Shipped fix to [prevent duplicate email checks](https://github.com/{organization}/{repository}/pull/{pull_request_number})"

## Slack activity

- Try to search slack for my interactions for {previous_workday}.
- **IMPORANT**: Ensure the messages you are querying are `after:{previous_workday} before:{today}`.
- **IMPORANT**: When searching Slack, explicitly specify date ranges with the current year.
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

Geekbot should ask three questions, but is subject to change.

1. What have you done since yesterday? (On Monday, use "What have you done since Friday?")
2. What will you do today?
3. Anything blocking your progress?

**Always provide the final standup in a markdown code block** using the three headers above.

### Section guidance

- **"What have you done since {previous_day_name}?"**: Include work completed on the previous workday (Friday if Monday, yesterday otherwise). This captures work from the last standup through end of that day.
- **"What will you do today?"**: Include work already done today AND planned work for the rest of the day. This section captures today's goals, including items already accomplished. Things done earlier today should appear here, not in "What have you done."
- On Monday, change the first header to "What have you done since Friday?"

### Expected outcome example

```md
## What have you done since yesterday?

- #proj-{project_channel}
  - Shipped policy PRs ({frontend_package} and {backend_service})
  - Shipped [presentation mode change tracking](https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number})
  - Opened fix to [prevent duplicate email checks from being made](https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number})
  - Opened fix to [resolve issue with incorrect email matched lockup](https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number})
  - Opened fix to [handle fallback / edge case where profile hydration fails](https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number})
  - Sync meeting

## What will you do today?

- #proj-{project_channel}
  - Shipped all PRs I’ve opened yesterday (last three mentioned PRs)
  - Opened a PR to [ensure the dismiss post message only posts after the iframe has loaded](https://app.graphite.dev/github/pr/{organization}/{repository}/{pull_request_number})
  - Implement the animation from the button to card presentation mode
  - Upgrade {internal_package} package in {backend_service} to get the updated fonts in {backend_service}
  - Start writing the bug hunt document
- General
  - Experience backlog grooming

## Anything blocking your progress?

-
```

## Final Output Format

**CRITICAL**: Always provide the final standup message in a raw markdown code block using triple backticks (```md). This ensures the user can copy and paste the content directly into Geekbot without formatting issues.

## Side effects

I want to use these reports to put together context for my impact reviews as well. To do this, you will need to create a new folder for the first report I make for each week. My first report for each week could take place on any day given holidays and vacation time.

1. For the first report of each week, ensure that a new folder exists in `/Users/quintonchester/Activity/yyyy-ww` that correlates to the year and week number, `yyyy-ww`.
   1. Week numbers should be non-zero based with the first week starting with week number 1.
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
