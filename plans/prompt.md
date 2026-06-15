# SOURCE OF TRUTH

Primary work queue is @docs/issues.

Use @plans/prd.md as product context, not as the task queue.

Also read:

- @CONTEXT.md for domain language and relationships
- @docs/product-direction.md for product/UI direction
- @docs/development-notes.md for implementation notes
- @docs/adr for architectural decisions
- the selected file inside @docs/issues

You've been passed recent git commits (SHA, date, full message). Review these with the issue snapshot to understand what was already done and what should happen next.

# ISSUE SELECTION

You've also been passed a docs/issues snapshot.

Pick exactly one issue file from @docs/issues.

Selection rules:

1. Prefer the lowest-numbered issue with unchecked acceptance criteria.
2. Skip issues whose `Blocked by` issue files still have unchecked acceptance criteria.
3. If an issue is broad, complete the smallest unchecked acceptance criterion in that issue.
4. If all issues are complete, emit exactly `<promise>NO MORE TASKS</promise>` as the final line.

Before coding, state the selected issue path and the exact acceptance criterion you will complete.

# SKILL GUIDANCE

Use skills only when they match the selected issue:

- Use `$tdd` for behavior/domain changes or bug fixes.
- Use `$flutter-add-widget-test` for UI acceptance criteria needing widget coverage.
- Use `$flutter-build-responsive-layout` for layout work across Android/Web.
- Use `$flutter-fix-layout-issues` for overflows or constraint bugs.
- Use `$flutter-add-integration-test` for full user flows.
- Use `$code-simplifier` after tests pass if touched code got more complex.
- Use `$diagnose` only when blocked by failing tests, `flutter analyze`, or unclear bugs.
- Use `$review` before final commit when the change touches shared behavior or many files.

Do not use skills as ritual. Small issue can use one matching skill or none.

# EXPLORATION

Explore the repo and fill your context window with relevant information that will allow you to complete the task.

Prefer existing domain terms, widgets, storage APIs and docs over inventing new patterns.

# EXECUTION

Complete the task.

Only work on the selected issue and one small acceptance criterion unless the criterion cannot be completed without nearby checklist updates.

Update the selected issue file:

- Mark completed acceptance criteria with `[x]`.
- Leave still-open criteria unchecked.
- Do not mark `flutter analyze` or `flutter test` complete unless you ran them and they passed.
- If blocked, add a short note under a `## Notes` section and output exactly `<promise>ABORT</promise>` as the final line.

If anything blocks your completion of the task, output exactly `<promise>ABORT</promise>` as the final line.

# FEEDBACK LOOPS

Before committing, run:

- `npm run analyze`
- `npm run test`

# COMMIT

Make a git commit. The commit message must:

1. Be a normal project commit message, with no required prefix.
2. Include selected issue path and acceptance criterion completed in the body.
3. Mention key decisions.
4. Mention files changed.
5. Mention blockers or notes for next iteration.

Keep it concise.

# FINAL RULES

ONLY WORK ON A SINGLE TASK.

Do not rewrite unrelated code.

Do not revert user changes.

Never ask whether to continue to the next issue or criterion. In AFK mode, the outer script decides whether to run another iteration.

Do not output `<promise>NO MORE TASKS</promise>` or `<promise>ABORT</promise>` unless that exact promise is the final line of your response.
