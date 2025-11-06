# dependencies.md — Dependency Management & DI

<tags>
scope: general
language: any
project: any
domain: dependencies
keywords: dependency, injection, DI, package, module, version, lockfile, security
</tags>

<primary_directive>
Keep dependencies minimal, explicit, and replaceable. Encapsulate third-party libraries and inject abstractions to preserve testability and flexibility.
</primary_directive>

<cognitive_anchors>
TRIGGERS: dependency, package, library, DI, container, module, version, lockfile
SIGNAL: Apply all rules when adding/upgrading/using dependencies or wiring DI.
</cognitive_anchors>

<rule_1 priority="HIGHEST">
ABSTRACTIONS & BOUNDARIES
- Define small interfaces at your boundary; do not expose vendor types publicly.
- Wrap third-party libraries behind adapters; keep call sites clean.
- Keep composition at the app/service root.
</rule_1>

<rule_2 priority="HIGH">
VERSIONING & REPRODUCIBILITY
- Pin versions; check in lockfiles where applicable.
- Prefer semver-aware updates; avoid blanket major jumps without review.
- Document upgrade strategy and breaking changes.
</rule_2>

<rule_3 priority="HIGH">
SECURITY & LICENSES
- Scan for vulnerabilities and incompatible licenses.
- Avoid unmaintained packages; have a replacement path.
- Never import secrets from code; use env/config.
</rule_3>

<rule_4 priority="MEDIUM">
DI STRATEGY
- Prefer constructor injection and small interfaces.
- Avoid global singletons; allow test-time substitution.
- Keep modules cohesive; avoid cyc dependency graphs.
</rule_4>

<pattern name="adapter_wrapper">
// Pseudocode: wrap vendor client
interface Mailer { send(to: Email, msg: Message): Result<void, Error> }
class SmtpMailer implements Mailer { /* uses smtp library internally */ }

// Public API consumes Mailer (not vendor types)
class NotifyUserUseCase { constructor(private mailer: Mailer) {} }
</pattern>

<pattern name="composition_root">
// Wire dependencies at the edge
const cfg = loadConfig()
const mailer = new SmtpMailer(cfg.smtp)
const notify = new NotifyUserUseCase(mailer)
</pattern>

<checklist>
☐ Vendor types not leaked through public APIs
☐ Versions pinned; lockfile updated
☐ Security/license checks documented
☐ DI via constructors; globals avoided
☐ Clear upgrade notes and fallbacks
</checklist>

<avoid>
❌ Singleton-heavy design
❌ Re-exporting vendor namespaces
❌ Unpinned versions and hidden transitive risks
❌ Tight coupling across modules
</avoid>

<review>
- Verify build reproducibility
- Confirm testability via fakes/adapters
- Note maintenance plan for critical deps
</review>
