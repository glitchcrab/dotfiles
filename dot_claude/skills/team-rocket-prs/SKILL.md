---
name: team-rocket-prs
description: Fetches the giantswarm/github team-rocket.yaml repository list and summarises open pull requests (titles only) for all repos in the giantswarm org.
---

# Team Rocket PR Summary Skill

When this skill is invoked, follow these steps exactly:

## Step 1 — Fetch the repository list

Use `mcp__github__get_file_contents` to fetch the file:
- owner: `giantswarm`
- repo: `github`
- path: `repositories/team-rocket.yaml`

The response is a YAML list. Each item has a `name` field — that is the repository name. Extract all `name` values, but ignore the `mctl` repo.

## Step 2 — Fetch open PRs in parallel

For **every** repository name extracted in Step 1, call `mcp__github__list_pull_requests` with:
- owner: `giantswarm`
- repo: `<name>`
- state: `open`

Issue **all** calls in a single parallel batch (one tool call per repo, all in the same message) to minimise latency.

## Step 3 — Summarise

Present the results grouped by repository. For each repo:

- If it has open PRs, list them as bullet points showing only the PR title and a link to the PR on GitHub. Append `[draft]` for draft PRs.
- If it has no open PRs, write `— none`.

Use this format:

**<repo-name>**
- PR title one - link
- PR title two [draft] - link

**<repo-name-2>** — none

Do not include PR bodies, authors, or any other metadata — numbers, titles and links only.
