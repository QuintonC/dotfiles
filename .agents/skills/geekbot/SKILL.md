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

## Before you start

- Connect the Slack, calendar, GitHub, and people-directory integrations before searching. They may be off by default, and they can time out after a period of inactivity, so check rather than assume. Newly enabled tools sometimes take a moment to appear.
- Run the `tuple-sync` skill first. Tuple pairing calls are ad-hoc, never on the calendar, and invisible to the daily note. `tuple transcription list --after {date} --before {date} --format json` returns `[]` when there were none.

## Overarching goal

Prepare a raw markdown message for the `{team_standup_name}` Geekbot standup in Slack:

- Read today's daily note at `~/quintonc/engram/daily/{yyyy-mm-dd}.md` (e.g., `2026-04-17.md`) if it exists.
  - This is the running journal for the day — meetings prepped for, work noted, decisions made, and personal `// ` comments.
  - Weight it heavily for "What did you do today?".
  - Treat it as one source among several — the daily note does NOT capture in-flight GitHub PR/issue activity or Slack threads.
  - Always cross-reference with calendar, Slack, and GitHub for the complete picture.
- Look at the previous standup entry stored in `~/quintonc/activity/yyyy-ww/{previous_day_number}.md`.
  - **IMPORTANT**: On Monday, the previous standup file is in the **previous week's folder** (e.g., if today is week 13, look in the week 12 folder for `5.md`).
  - If no files exist in the activity directory, fall back to Slack search to find previous interactions with the Geekbot application.
  - If the user didn't respond the previous day, reference the last time they responded to the Geekbot survey.
  - Check the previous standup's **"What will you do tomorrow?"** section to verify follow-through on planned work.
- Use the calendar integration to get events for today and tomorrow.
  - Avoid referencing common events such as Lunch, Focus time, or anything marked Personal. Focus on project meetings and one-on-ones.
  - For today's events (to populate "What did you do today?"), bound the window from midnight today to midnight tomorrow, 20 results.
  - For tomorrow's events (to inform "What will you do tomorrow?"), bound it from midnight tomorrow to midnight the day after, 20 results.
  - **An invite on the calendar is not attendance.** Check the user's own response status on each event. Drop anything declined. Where the invite is still unanswered, look for corroborating Slack activity in that window, and ask rather than assume.
- If an issue linked in the previous "What will you do tomorrow?" wasn't closed (through a linked PR), check:
  - Is the linked PR waiting for reviewers?
  - Is this PR approved but not yet shipped (still sitting in a merge queue, or awaiting a deploy)?
  - Is there a linked PR?
- From there, ask clarifying questions about the status of the work. The user may not have gotten to it, so capture any disruptions to that flow.
  - If a PR is mentioned directly, run through the same checks.
  - Prompt for more information on unclear items. For example:
    > You mentioned you were going to investigate an action item from {incident_channel} with @{colleague}. Were you able to resolve the issue?

## Accuracy requirements

- Focus on actual work completed, not speculation.
- Only include activities that actually happened based on evidence.
- Do not invent or assume activities (like "on-call rotation" or "reviewing PRs"); reference only events returned from the calendar.
- If unsure about something, omit it rather than guess.
- **Verify the date of every item before listing it.** `gh search prs --updated={date}` returns PRs *touched* that day, not merged or reviewed that day. Confirm each one with `gh pr view {n} --repo {owner}/{repo} --json mergedAt` and `gh api repos/{owner}/{repo}/pulls/{n}/reviews --jq '.[] | "\(.user.login) \(.state) \(.submitted_at)"'`. A PR merged Tuesday does not belong in Thursday's standup.
- Match activities to what was said in the previous standup.
- **Meetings ALWAYS go under the "General" section**, never under project-specific sections.
- Do not include activities the user didn't actively participate in (e.g., threads only observed but not contributed to).
- Never drop links when referencing items. Always preserve link references when moving or editing text.

## Slack handles

- When mentioning people by name, use their Slack handle.
- Check `~/quintonc/engram/people/{slug}/README.md` first. The handle is usually on the first line (e.g. ``Slack `@handle` ``, ``Slack `handle` ``, ``Slack `Person` ``). This is faster and more reliable than a lookup.
- If the people file has no handle, fall back to Slack user search and profile lookup, and take the **display name**, not the email prefix.
- Do not guess handles from message text.
- Handles go on 1:1s and 1:1:1s only. Group meetings, including named syncs, get the meeting name alone.

## User-provided context

- When the user provides links during clarifying questions (docs URLs, Slack threads), include those links in the final output.
- Use markdown link format: `[descriptive text](URL)`.
- This includes internal documentation links, Slack thread permalinks, and any other references shared.

## Formatting preferences

- Avoid emdashes (—) in the output.
- **One line per item.** First drafts of this standup run three to four times too long. Cut explanatory sub-bullets and low-substance items before showing anything.
- Split independent thoughts into separate sub-items. Do not chain unrelated thoughts with semicolons.
- Name and link the concrete artifact. No bare "the flag" or "the PR".
- Call it "the tech design", unprefixed. Never "the {Feature} tech design".
- No time slots on meetings. List the meeting name alone.
- Nest detail under the artifact it belongs to, not as a sibling. Findings about a PR are sub-items of that PR's line.
- Never surface private DM content: team moves, personnel, manager confidences.
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
  - For a link to a review tool that is not GitHub, resolve the title with that tool's own CLI, not `gh`. See the section below.
- For example: "Shipped fix to [prevent duplicate email checks](https://github.com/{organization}/{repository}/pull/{pull_request_number})".
- **A link is part of the item, not decoration.** When condensing, reordering, or rewording an item at the user's request, carry its link along. Never let a rewrite turn a linked item into a bare one.

## Review tools the `gh` CLI cannot reach

Some repositories are reviewed through a tool other than GitHub's own UI, with its own PR numbering and its own API. Treat each one as a separate source that `gh` is blind to, and never assume a quiet `gh` result means a quiet day.

You are looking at one of these when:

- `gh pr view {n} --repo {owner}/{repo}` cannot resolve a PR number that the review tool's URL clearly shows, because the two systems number PRs independently.
- `gh search prs --owner={org}` returns nothing for work you have direct evidence happened.

When that happens, find the repo's own review CLI and use its API passthrough. Many mirror `gh api` one for one, so a mechanical `gh api {endpoint}` to `{cli} api {endpoint}` swap usually works. Check `--help` for a subcommand that lists pull requests and one that makes authenticated API requests. Run it from inside the relevant checkout if it infers the repo from the working directory, otherwise pass the fully qualified repo path.

Pull these for the standup:

- PRs the user authored, sorted by most recently updated.
- PRs where review was requested of the user.
- Per PR, the title, state, and creation timestamp.
- Per PR, the reviews list with reviewer, state, and timestamp. This is the only reliable way to confirm an approval landed today.
- Per PR, the inline review comments. A review left as comments never appears as a formal approval.

Expect these limits, and do not burn turns rediscovering them:

- **No search endpoint.** These tools usually expose per-PR reads and no query interface, so you cannot ask "what did I review today" directly.
- **No repo-wide comment listing.** The GitHub-shaped endpoint for it typically rejects the request.
- **`updated_at` is not a usable "today" filter** in a large monorepo. Background churn rewrites it constantly, so every open PR looks freshly updated.

Because there is no search, build the candidate list from Slack: the PRs the user linked, was asked to review, or discussed that day. Then check reviews and comments on each. The "review requested of me" listing catches whatever Slack missed.

## Slack activity

- Search Slack for the user's activity from the previous standup through now.
- Resolve the user's own Slack ID first, then search across public and private channels with `from:<@{user_id}> after:{yesterday} before:{tomorrow}` to catch late-day activity from after the previous standup.
- **IMPORTANT**: When searching Slack, explicitly specify date ranges with the current year.
  - Edge case: for the first report of the new year, refer to the most recent activity since the last update in Slack.
- **One page is not a day.** Results cap at 20 per page, so a full day typically runs 6 to 8 pages. Sort by timestamp ascending and follow the pagination cursor until the timestamps reach end of day. Stopping at the first page silently truncates the standup to the morning.
- Turn off surrounding-message context after the first page. Thread context repeats on every result and crowds out the messages you need.
- Summarize updates to at most 3 bullet points per channel. Format with the channel name as the first-level list item and sub-items as the second level:

  ```md
  - #proj-{project_channel}
    - Activity summary 1
    - Activity summary 2
    - Activity summary 3
  ```

## Tidiness

- Use the proper tools: the Slack, calendar, and people-directory integrations, the `gh` CLI for GitHub, and the repo's own review CLI for anything GitHub cannot see.
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
  - Participated in [#help-{team} thread on topic](https://{workspace}.slack.com/archives/{channel_id}/{message_ts})
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
3. Check the whole week, not just yesterday. List the week folder and report **every** missing weekday file up to today, and note whether the matching daily notes exist. Offer to backfill them from Slack and GitHub. A missing week folder means every day so far is unlogged.
4. At the start of the following week, put together a `summary.md` for the prior week, including only:
   - Highlights from the prior week from the user's own contributions.
   - Summarized information for projects contributed to or championed (use the people-and-projects directory for this information).

## Iterations and corrections

- If the user requests changes, maintain the same raw markdown code block format for all iterations.
- Provide each revised version in a new markdown code block.
- **Keep a running list of every item the user asked to drop, and never reintroduce one.** A later revision that restores dropped content is the most irritating failure mode of this skill. Re-read the drop list before emitting each new version.
- "Drop it" means delete the item. It does not mean reword it, shorten it, or move it elsewhere.
- When the user asks to move an item to another section, move it. Do not leave a copy behind, and do not decide it fits better where it was.
- If edits empty out a channel section, remove the header too, and say so in one line.
- Apply corrections literally first. If a correction conflicts with the evidence, make the change the user asked for where you can, then flag the conflict separately with the data behind it.
