# mcp-tools-usage.md — Assistant Tooling & Safety Conventions

<tags>
scope: general
language: any
project: any
domain: tooling
keywords: MCP, tools, sandbox, approval, shell, apply_patch, plan, safety
</tags>

<primary_directive>
Use tools deliberately, safely, and transparently. Minimize risk, ask before destructive actions, and keep users in control. Prefer small, reversible steps with clear context.
</primary_directive>

<cognitive_anchors>
TRIGGERS: tool, shell, patch, apply_patch, read, write, network, approval, plan, sandbox
SIGNAL: Apply when using assistant tools or automation.
</cognitive_anchors>

<rule_1 priority="HIGHEST">
APPROVAL & SAFETY
- Ask before destructive or high-impact actions (e.g., rm, reset, network installs).
- Respect sandbox and approval modes; escalate only with justification.
- Never exfiltrate secrets; redact sensitive data in logs.
</rule_1>

<rule_2 priority="HIGH">
SMALL, TRANSPARENT CHANGES
- Use `apply_patch` for focused edits; avoid unrelated churn.
- Summarize intent before running commands; group related actions.
- Prefer `rg` for fast searches; read files in ≤250-line chunks.
</rule_2>

<rule_3 priority="HIGH">
PROGRESS & PLANNING
- Maintain a lightweight plan for multi-step tasks; keep exactly one step in progress.
- Provide concise progress updates; avoid noise.
- Validate work with available tests or builds when appropriate.
</rule_3>

<rule_4 priority="MEDIUM">
NETWORK & ENVIRONMENT
- Only use network when necessary and approved; document purpose.
- Do not modify files outside the workspace root without explicit approval.
- Keep changes consistent with repo style; avoid adding new tooling unless requested.
</rule_4>

<pattern name="command_preamble">
// Before running tools, state intent succinctly
// "I’ll scan the repo, then add config and tests."
</pattern>

<pattern name="focused_patch">
// Example apply_patch envelope
// *** Begin Patch
// *** Update File: path/to/file
// @@
// - old
// + new
// *** End Patch
</pattern>

<checklist>
☐ Intent stated; user informed
☐ Minimal, scoped changes
☐ Destructive actions confirmed
☐ Respect sandbox/approval settings
☐ Validation performed when feasible
</checklist>

<avoid>
❌ Large, unrelated diffs
❌ Hidden network access or privileged commands
❌ Reading huge files in one go
❌ Leaking secrets or tokens
</avoid>

<review>
- Re-check changes match the stated intent
- Confirm no unintended files were modified
- Provide next-step suggestions briefly
</review>
