# Rule Loading Guide (Tag-Based)

This index enables progressive, tag-driven rule loading. Always load this file first, then select the minimal set of rules by matching tags to the current repo and task.

## Rule File Tag Schema
Each rule file should include a `<tags>` block near the top with key–value pairs:

```
<tags>
scope: general | language | project
language: any | swift | typescript | go | rust | java | kotlin | python | ruby | …
project: any | <project-name>
domain: general | testing | dependencies | view | view-model | commits | tooling | …
keywords: comma-separated,freeform,task,signals
</tags>
```

Notes:
- `scope` determines applicability layer.
- `language` narrows to a language; `any` means cross-language.
- `project` narrows to a specific project; `any` for reusable rules.
- `domain` is the primary topic of the rule.
- `keywords` help match freeform requests.

## Directory Layout
- `ai-rules/general/*.md` → general, cross-language rules (scope: general)
- `ai-rules/languages/<lang>/*.md` → language-specific rules (scope: language)

Examples:
- `ai-rules/general/general.md` (general/core)
- `ai-rules/general/testing.md` (general/testing)
- `ai-rules/languages/swift/entry-point.md` (language/swift/core)
- `ai-rules/languages/swift/view.md` (language/swift/view)

## Selection Algorithm
1) Detect language(s)
   - Inspect repo files to infer primary languages (e.g., `*.swift`, `Package.swift`, `package.json`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `requirements.txt`). If unknown, ask the user.

2) Load base rules (always)
   - Global base: `ai-rules/general/general.md`
   - Language base: for each detected language, load `ai-rules/languages/<lang>/entry-point.md`
     (Provides language idioms and directs which language domains to load next.)

3) Load language-specific domain rules
   - scope: language, language: <detected>
   - Domains relevant to current task (e.g., view/view-model for UI requests; testing for test tasks)

4) Expand by keywords
   - For the user request, match rule `keywords` and `domain` to include any additional relevant rules

5) Keep it minimal
   - Load only what’s directly relevant; refresh set when switching tasks/contexts

## Quick Reference
// New feature work:
// Load: general/general.md, languages/<lang>/entry-point.md,
//       then scope=language(lang=<detected>, domains=dependencies,view,view-model)

// Writing tests:
// Load: general/general.md, languages/<lang>/entry-point.md, general/testing.md,
//       then scope=language(lang=<detected>, domain=testing)

// Reviewing code or preparing PR:
// Load: scope=general(domain=general,commits)

## Built-in Domains (suggested)
- general, testing, dependencies, view, view-model, commits, tooling

## Implementation Notes
- All rule files live under `ai-rules/` and subfolders listed above.
- If a matching rule is missing, proceed without error; ask the user if more detail is needed.
- Prefer language-specific over general when rules conflict.
