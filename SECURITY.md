# Security Policy

## Scope

This repository contains public, non-sensitive documentation, scripts, baseline definitions, and example audit evidence for a Windows endpoint security baseline.

Security reports are appropriate when they concern:

- exposed secrets, credentials, private keys, certificates, or sensitive host data;
- unsafe script behavior that could alter or weaken a system unexpectedly;
- command injection, path traversal, arbitrary code execution, or privilege-boundary issues;
- misleading verification logic that could produce materially incorrect security results;
- integrity, provenance, or signature-verification defects;
- GitHub Actions or repository configuration weaknesses that could expose tokens or allow untrusted code execution.

Documentation disagreements, feature requests, control-mapping proposals, and non-sensitive reproducibility problems may be reported through a normal GitHub issue.

## Supported versions

| Version | Status |
|---|---|
| `v2026.01` | Supported reference baseline |
| Earlier experimental material | Best effort only |

## Reporting a vulnerability

Do not include sensitive details in a public issue.

Use GitHub's private vulnerability reporting feature for this repository when it is available:

1. Open the repository's **Security** tab.
2. Select **Report a vulnerability**.
3. Provide a concise description, affected files or workflows, reproduction steps, impact, and any proposed mitigation.

If private vulnerability reporting is not available, open a public issue containing only a minimal, non-sensitive notice that a private security contact is required. Do not include exploit details, secrets, host identifiers, certificate material, or personal information.

## What to include

A useful report should include:

- affected branch, tag, baseline version, or commit;
- affected file, script, workflow, or evidence artifact;
- technical impact;
- reproducible steps using non-sensitive sample data;
- expected and observed behavior;
- suggested remediation, when available.

## Handling expectations

Reports will be assessed for reproducibility, impact, and scope. Valid issues may result in documentation corrections, script changes, evidence invalidation notices, or a new baseline version.

No response-time or remediation-time service-level agreement is guaranteed for this public reference project.

## Disclosure guidance

Please allow reasonable time for assessment and remediation before public disclosure. Coordinated disclosure is preferred.

## Security limitations

- The repository is not an external attestation service.
- Local evidence can be affected by administrative compromise.
- Cryptographic verification does not independently prove that the original observation was complete or trustworthy.
- Signer trust requires a separately trusted certificate or chain.
