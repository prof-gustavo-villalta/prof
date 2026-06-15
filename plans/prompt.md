# PRD

Pull @plans/prd.md into your context.

Also read:

- @CONTEXT.md for domain language and relationships
- @docs/product-direction.md for product/UI direction
- @docs/development-notes.md for implementation notes
- @docs/adr for architectural decisions
- @docs/issues for existing planned slices

You've been passed a file containing the last 10 RALPH commits (SHA, date, full message). Review these to understand what work has been done.

# TASK BREAKDOWN

Break down the PRD into tasks.

Make each task the smallest possible unit of work. Aim for one small behavior or one small structural improvement per task.

# TASK SELECTION

Pick the next task.

If there are no more tasks, emit <promise>NO MORE TASKS</promise>.

# EXPLORATION

Explore the repo and fill your context window with relevant information that will allow you to complete the task.

Prefer existing domain terms, widgets, storage APIs and docs over inventing new patterns.

# EXECUTION

Complete the task.

Only work on a single task.

If anything blocks your completion of the task, output <promise>ABORT</promise>.

# FEEDBACK LOOPS

Before committing, run:

- `npm run analyze`
- `npm run test`

# COMMIT

Make a git commit. The commit message must:

1. Start with `RALPH:` prefix
2. Include task completed + PRD reference
3. Mention key decisions
4. Mention files changed
5. Mention blockers or notes for next iteration

Keep it concise.

# FINAL RULES

ONLY WORK ON A SINGLE TASK.

Do not rewrite unrelated code.

Do not revert user changes.
