---
description: Stage all changed files and perform git commit
agent: tech-lead
---

Stage all changed files and commit them with a clear, detailed message that describes the relevant code changed. Conventional Commits format. Subject is a one-line summary; body details the specific code changes for reviewers skimming the log.

## Workflow

1. Run `git status` and `git diff` (or `git diff --staged`) to review the actual changes
2. Confirm the diff is one logical change — if it mixes unrelated concerns, ask the user before splitting into multiple commits
3. Stage relevant files: `git add <files>` (never `git add .` or `-A` blindly; never stage secrets, `.env`, build artifacts, or lock files unless explicitly asked)
4. Re-check `git diff --staged` before committing
5. Commit with the message formatted per the rules below
6. Confirm with `git log -1 --stat`

## Message format

**Subject line:**
- `<type>(<scope>): <imperative summary>` — `<scope>` optional but recommended
- Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding"
- ≤50 chars when possible, hard cap 72
- No trailing period
- Breaking changes: append `!` before the colon — `feat(api)!: ...`

**Body (always present, details the code changed):**
- Bullets `- ` summarizing each meaningful change: area → what changed
- Reference specific files and line numbers when relevant: `` `src/auth/session.ts:88` ``
- Name the key symbols, functions, classes, types, or config keys touched, in backticks
- Call out breaking changes, migration notes, and follow-ups explicitly
- Wrap at 72 chars
- Reference issues/PRs at end: `Closes #42`, `Refs #17`

## What goes in the body

- Specific files changed and the nature of the change (added, removed, modified, renamed)
- Key symbols/functions/classes/types added or modified
- The *why* only when non-obvious from the diff
- Side effects, follow-ups, performance characteristics, or caveats
- Breaking changes called out with `BREAKING CHANGE:` prefix

## What NEVER goes in

- "This commit does X", "I", "we", "now", "currently" — the diff says what changed
- "Generated with..." or AI attribution unless the project's own rules require an attribution trailer
- Emoji (unless the project's convention requires it)
- Vague summaries like "various improvements", "fix stuff", "updates"
- Restating the subject line in different words
- Co-authored-by or other trailers unless asked

## Examples

Diff: new endpoint + migration + tests

❌
```
feat: add profile endpoint
```

✅
```
feat(api): add GET /users/:id/profile

- Add `getUserProfile` handler in `src/routes/users.ts:42` returning
  slimmed payload (id, name, avatar) instead of full user
- Add migration `2026_07_10_create_user_profiles.sql` with `bio`
  and `preferences` JSONB columns; index on `user_id`
- Add `UserProfile` type in `src/types/user.ts`
- Add integration tests in `tests/users/profile.test.ts` covering
  404, 401, and happy path

Mobile client needs profile data without the full user payload
to reduce LTE bandwidth on cold-launch screens.

Closes #128
```

Diff: bug fix

❌
```
fix: null pointer
```

✅
```
fix(auth): guard null user in session refresh

- Add null check in `refreshSession` (`src/auth/session.ts:88`)
  before accessing `user.email`; returns 401 if session is stale
- Add regression test in `tests/auth/session.test.ts` for
  expired-session case
- Previously threw 500 on stale cookies; now returns 401

Closes #203
```

Diff: breaking API change

✅
```
feat(api)!: rename /v1/orders to /v1/checkout

- Update route in `src/routes/index.ts:14` and aliases in
  `src/routes/orders.ts`
- Update client SDK in `packages/sdk/src/client.ts:81`
- Deprecate `/v1/orders` with 410 + `Sunset` header; remove
  fully in v3

BREAKING CHANGE: clients on /v1/orders must migrate to
/v1/checkout before 2026-09-01. Old route returns 410 with
migration guide link in response body.

Closes #341
```

## Auto-clarity

Always include body for: breaking changes, security fixes, data migrations, anything reverting a prior commit, or changes touching more than one file. Never compress these into subject-only.

## Boundaries

- Does not push, does not amend published commits, does not rebase or force-push
- Does not skip hooks (`--no-verify`) unless the user explicitly asks
- Does not stage secrets, `.env*`, `node_modules`, build outputs, or lock files unless explicitly asked
- Asks for confirmation when the diff mixes unrelated concerns (suggests splitting)
- If `git status` is clean, reports nothing to commit and exits
