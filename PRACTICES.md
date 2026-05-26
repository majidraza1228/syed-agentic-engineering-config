# Claude CLI — Best Practices for Agentic Developers

Practical patterns for getting the most out of Claude Code across solo and team workflows.

---

## 1. Project Structure

A well-structured project gives Claude immediate context without extra prompting.

```
my-project/
├── CLAUDE.md               # Claude's standing instructions for this project
├── product-os/
│   ├── PRODUCT-CONTEXT.md  # What the product does, who it's for, key constraints
│   ├── prd/                # Feature specs — Claude checks here before building
│   ├── sprints/
│   │   └── current.md      # Active sprint; Claude reads this to stay in scope
│   └── decisions/
│       └── log.md          # Architecture decisions log
├── src/
├── tests/
└── README.md
```

### CLAUDE.md — the most important file

`CLAUDE.md` is loaded automatically at the start of every Claude Code session. Use it to:

- Define the tech stack and conventions
- Set constraints ("never use `git add -A`", "always write tests before code")
- Specify which directories to read before touching any feature
- List commands Claude is allowed to run without prompting

**Minimal example:**

```markdown
# Project: payments-api

Stack: Python 3.11, FastAPI, PostgreSQL, SQLAlchemy

## Rules
- Read `product-os/prd/` before adding any feature
- Tests live in `tests/` and must pass before any commit
- Never modify migrations manually — use `alembic revision --autogenerate`

## Allowed commands (no confirmation needed)
- pytest, ruff, mypy, alembic
```

The more specific your `CLAUDE.md`, the less you repeat yourself across sessions.

---

## 2. Effort Level Strategy

Use the 4-pane `t` workspace to route tasks by cognitive load:

| Pane | Effort | Best for |
|------|--------|----------|
| High-1 | `high` | System design, hard bugs, security review, novel algorithms |
| High-2 | `high` | Second opinion on High-1's output, parallel deep work |
| Medium | `medium` | Feature implementation, refactoring, code review |
| Low | `low` | File search, quick edits, documentation, grep tasks |

**Pattern: think → delegate → verify**

1. Use a `high` pane to plan the approach
2. Paste the plan into a `medium` pane to implement
3. Use `low` for fast follow-up (check a file, run a command, update a comment)

This prevents burning high-effort thinking budget on trivial tasks.

---

## 3. Data Structures for Agent Context

Structure information so Claude can parse it reliably — avoid prose where a table or list works.

### Prefer structured formats in prompts

```
# Bad — hard to parse
"The user table has id, name, email, created_at and the product table has id, name, price, user_id"

# Good — scannable
users:    id (PK), name, email, created_at
products: id (PK), name, price, user_id (FK → users.id)
```

### Schema files over inline descriptions

Keep a `schema.sql` or `models.py` in the project root and reference it:

```markdown
# CLAUDE.md
Database schema: see `db/schema.sql`. Never infer column types — always check the file.
```

### Decision log format

In `product-os/decisions/log.md`, use a consistent entry format:

```markdown
## 2026-05-26 — Use PostgreSQL JSONB for metadata

**Context:** metadata fields vary per product type; 12+ columns would be sparse
**Decision:** single `metadata JSONB` column with GIN index
**Rejected:** EAV table (too many joins), separate tables per type (migration overhead)
**Owner:** syed
```

Claude reads these entries to avoid re-litigating settled decisions.

---

## 4. Efficient CLI Patterns

### Session naming

Always name sessions for easy resume:

```sh
claude --model claude-opus-4-7 --effort high --name payments-refactor
```

Resume by name:

```sh
claude --resume payments-refactor
```

### Slash commands for repeated workflows

Create project-specific slash commands in `.claude/commands/`:

```markdown
# .claude/commands/review.md
Review the staged changes for correctness, security issues, and test coverage.
Check `product-os/prd/` to confirm the changes match the spec.
Output: summary of issues found, or "LGTM" if none.
```

Run as `/review` inside any Claude Code session.

### Pipe Claude into your workflow

```sh
# Summarize a file non-interactively
cat src/payments.py | claude -p "summarize the public API of this module"

# Pipe git diff into a review
git diff main | claude -p "review this diff for bugs and security issues"

# Generate a commit message
git diff --staged | claude -p "write a concise git commit message for these changes"
```

### Use --append-system-prompt for one-off context

```sh
claude --append-system-prompt "$(cat product-os/PRODUCT-CONTEXT.md)" --effort high
```

Useful when starting a session on a complex feature without wanting to copy-paste context manually.

---

## 5. Context Window Hygiene

The status line shows your context usage — act before it fills up.

| Usage | Action |
|-------|--------|
| < 50% | Normal — no action needed |
| 50–75% | Start wrapping up or `/clear` non-essential history |
| 75–90% | `/compact` to summarize and free space |
| > 90% | Start a new session; paste only the relevant snippet |

**`/compact`** summarizes the conversation into a shorter form while preserving intent — use it over `/clear` when you need to keep the thread.

**Pattern: one session per task**

Don't accumulate unrelated work in a single session. Each pane in the `t` workspace should own one task. When it's done, start fresh — this keeps context lean and reasoning sharp.

---

## 6. Multi-Agent Patterns

### Parallel research, serial implementation

```
High-1: "Investigate the best approach for X — outline options with tradeoffs"
High-2: "Review this schema design for issues — be adversarial"
Medium:  implement once High-1 reports back
Low:     run tests, check files, grep for usages
```

### Worktrees for parallel feature work

```sh
claude --worktree --effort medium --name feature-a
claude --worktree --effort medium --name feature-b
```

Each worktree gets an isolated git branch — no conflicts between parallel agents.

### Passing output between panes

Use files as the message bus between panes:

```sh
# In High-1 pane — output a plan
claude -p "design the auth module" > /tmp/auth-plan.md

# In Medium pane — implement from the plan
claude --append-system-prompt "$(cat /tmp/auth-plan.md)" --effort medium
```

---

## 7. Avoiding Common Mistakes

| Mistake | Fix |
|---------|-----|
| Giving vague tasks ("fix the bug") | Be specific: file, line, expected vs actual behavior |
| Letting context fill up silently | Watch the status bar; `/compact` at 75% |
| Using `high` effort for simple tasks | Reserve `high` for reasoning-heavy work; use `low`/`medium` for everything else |
| Not having a `CLAUDE.md` | Every project should have one — Claude reads it on every session start |
| Accepting the first output without review | Always read diffs; Claude can be confidently wrong |
| One massive session for all work | One session per task — keeps reasoning focused |
