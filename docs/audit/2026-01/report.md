\# System Security Baseline Report — January 2026



\## Executive Summary

This document presents a security baseline for a single Windows endpoint

(MAQUEOSYSTEM). The baseline focuses on platform integrity controls,

including virtualization-based security, application control enforcement,

and disk protection.



All evidence was collected locally via PowerShell and cryptographically

hashed to ensure integrity.



---



\## Scope

\- Asset type: Windows endpoint

\- Hostname: MAQUEOSYSTEM

\- OS build: 26200

\- Audit date: 2026-01-12



---



\## Baseline Controls



\### Virtualization-Based Security (VBS)

\- Status: Enabled and running

\- Evidence: `10\_device\_guard\_public.json`



\### Application Control (WDAC / HVCI)

\- Enforcement mode: Active

\- SecurityServicesRunning: `{2}`

\- SecurityServicesConfigured: `{2}`



This indicates Hypervisor-Enforced Code Integrity (HVCI) is enforced.



---



\### Secure Boot

\- Status: Enabled

\- Evidence: `12\_secure\_boot.txt`



---



\### Disk Encryption

\- Control: BitLocker

\- Status: Enabled

\- Evidence: `11\_bitlocker.json`



---



\## Evidence Integrity

All baseline evidence files were hashed using SHA-256.

The resulting hashes are recorded in `hashes.txt`.



Any modification to the evidence invalidates the baseline.



---



\## Standards Alignment



\### Microsoft

\- Windows Defender Application Control (WDAC)

\- Microsoft security baselines for hardened endpoints



\### Open Standards

\- Internet standards (RFCs) inform trust and integrity models

\- Governance references such as RFC 9389 are informational only



---



\## Notes

This baseline intentionally excludes user identities, network topology,

and runtime exposure to prevent sensitive data disclosure.



---



\## Change Control

This baseline represents a point-in-time snapshot.

Future changes require a new baseline and report.



