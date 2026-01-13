\# Security Audit Methodology



\## Objective

This repository documents point-in-time security baselines for a Windows endpoint.

The objective is to provide verifiable, non-sensitive evidence of security posture.



\## Collection Method

All evidence is collected locally using PowerShell with administrative privileges.



\## Evidence Scope

Only control state and enforcement signals are included.

User data, network topology, and runtime telemetry are excluded.



\## Integrity Controls

All evidence artifacts are hashed using SHA-256.

Hashes are published alongside the evidence.



\## Disclosure Model

\- Private: full system state

\- Public: reduced baseline artifacts



\## Versioning

Each audit snapshot is immutable and stored under docs/audit/YYYY-MM.



