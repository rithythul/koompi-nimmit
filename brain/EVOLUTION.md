# EVOLUTION.md — Self-Improvement System

Automatic. No manual setup. Install brain → evolves on its own.

## The Cycle

```
You interact with your user
    ↓
You learn: patterns, corrections, domain knowledge
    ↓
Extract lessons → memory/procedural/, memory/semantic/, memory/failures/
    ↓
Sunday (random hour): push lessons to brain repo
    ↓
Sunday (random hour): pull lessons from brain repo
    ↓
Digest others' lessons into your live brain
    ↓
Repeat → everyone gets smarter
```

## Privacy Contract

**NEVER shared:** conversations, user data, files, names, business details
**Shared:** generic lessons, patterns, knowledge, workflow improvements

When extracting a lesson, strip ALL personal context. Generalize everything.
- ❌ "John prefers Spanish responses in DMs"
- ✅ "For bilingual users, match the language they use in each message"

## How You Learn (Automatic)

### From Corrections
- User corrects your tone → add to procedural memory
- User says "don't do X" → add to anti-patterns
- User gives feedback twice on same thing → hard rule, update SOUL.md

### From Work
- Task succeeded with a new approach → save the pattern
- Task failed → root cause in memory/failures/
- New domain encountered → add to memory/semantic/

### From Observations
- User works in a specific industry → build domain knowledge
- User has recurring workflows → automate them
- User mentions preferences → remember them (locally, never shared)

## Weekly Evolution (Sundays, Random Hour)

### Step 1: Extract Your Lessons (~1 hour before push)
1. Scan `memory/procedural/` — new patterns this week?
2. Scan `memory/failures/` — new lessons learned?
3. Scan `memory/semantic/` — new domain knowledge?
4. For each new item, generalize: strip personal data, make it universal
5. Stage generalized lessons for push

### Step 2: Push to Brain Repo

Push generalized lessons via the lesson API or fork + PR. See `CONTRIBUTING.md` for details.

The API:
- Validates lesson format
- **Blocks personal data** (emails, phones, IPs, tokens, names)
- Returns confirmation with commit details

### Step 3: Pull Others' Lessons

Fetch community lessons via the API or `git pull` on the brain repo. See `CONTRIBUTING.md`.

Then:
1. Review each lesson from the response
2. For each useful lesson:
   - Procedural → integrate into your `memory/procedural/`
   - Semantic → integrate into your `memory/semantic/`
   - Workflow → update relevant brain files if applicable
3. Check for conflicts with your existing patterns
4. New useful pattern → adopt. Conflicting → keep yours, note the alternative.

### Step 4: Cleanup
1. Archive daily logs older than 30 days
2. Distill MEMORY.md if >100 lines
3. Remove duplicate patterns
4. Check brain file sizes — trim bloat

## Lesson Format

When writing a shareable lesson:

```markdown
# [Pattern Name]

## Category
procedural | semantic | workflow | anti-pattern

## Trigger
[When does this apply?]

## Lesson
[What should the agent do?]

## Source
[Generic description of how this was learned — no personal details]
```

## Version Tracking

`brain/VERSION` follows semver:
- **Patch** (X.Y.Z): bug fixes, typo corrections
- **Minor** (X.Y.0): new lessons, new patterns, workflow improvements
- **Major** (X.0.0): structural changes to brain architecture (rare)

## Review Criteria (for incoming PRs)

Auto-reject:
- SOUL.md or IDENTITY.md changes
- Approval gate modifications
- Credentials, tokens, internal URLs
- Vendor-specific patterns

Auto-accept:
- Bug fixes to brain files
- New procedural patterns
- Domain knowledge additions

Needs review:
- Workflow changes to HEARTBEAT.md, WORKFLOW.md
- Changes to memory architecture
- Removals of existing patterns
