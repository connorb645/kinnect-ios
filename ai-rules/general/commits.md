# commits.md — Commit Message Standards

<tags>
scope: general
language: any
project: any
domain: commits
keywords: commit, changelog, PR, review, conventional commits, release notes
</tags>

<primary_directive>
Write small, self-contained commits with clear, actionable messages. Explain the why, not just the what, and keep history useful for humans and tools.
</primary_directive>

<cognitive_anchors>
TRIGGERS: commit, message, changelog, PR, review, release, conventional commits
SIGNAL: Apply when preparing commits or PR descriptions.
</cognitive_anchors>

<rule_1 priority="HIGHEST">
CONVENTIONAL FORMAT
- Use `<type>(<scope>): <summary>` in present tense, imperative voice.
- Types: feat, fix, perf, refactor, docs, test, chore, ci, build, style.
- Keep summary ≤ 72 chars.
</rule_1>

<rule_2 priority="HIGH">
FOCUS & CLARITY
- One logical change per commit; avoid mixing refactors with behavior changes.
- In body, explain motivation, alternatives, and trade-offs.
- Reference issues/links as needed.
</rule_2>

<rule_3 priority="HIGH">
BREAKING CHANGES & META
- Use `BREAKING CHANGE:` footer for incompatible changes.
- Use `Co-authored-by:`/`Refs:` footers when applicable.
- Squash fixups locally before sharing.
</rule_3>

<pattern name="examples">
feat(auth): add TOTP enrollment flow

fix(api): handle 429 with exponential backoff

refactor(view-model): extract reducer and effects

docs(readme): document local setup and troubleshooting

perf(cache): avoid N+1 query on user listing
</pattern>

<checklist>
☐ Tests green; lints/formatters run
☐ Single responsibility; clear summary (≤72 chars)
☐ Body explains why and trade-offs
☐ Breaking changes clearly marked
☐ Related docs updated
</checklist>

<avoid>
❌ "wip" or unclear summaries
❌ Large, mixed commits hard to review
❌ Unexplained behavior changes
❌ Forgetting to update tests/docs
</avoid>

<review>
- Re-read commit subject/body for clarity
- Ensure diffs align with the stated intent
- Consider splitting or squashing as needed
</review>
