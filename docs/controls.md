\# Security Controls Mapping



\## Purpose

This document maps implemented security controls to their intended purpose,

risk mitigation goals, and architectural layer.



The objective is to demonstrate intentional control selection rather than

feature enablement.



---



\## Control: Secure Boot



\### Category

Platform Integrity



\### Layer

Pre-Boot Trust Boundary



\### Purpose

Ensure that only trusted boot components are executed during system startup.



\### Risk Mitigated

\- Bootkit persistence

\- Firmware-level tampering

\- Unauthorized OS loaders



\### Evidence

\- docs/audit/2026-01/evidence/12\_secure\_boot.txt



\### Limitations

Does not protect against vulnerabilities in trusted firmware.



---



\## Control: Virtualization-Based Security (VBS)



\### Category

Isolation \& Integrity



\### Layer

OS Integrity Boundary



\### Purpose

Isolate critical security components from the main operating system.



\### Risk Mitigated

\- Kernel memory tampering

\- Credential theft via LSASS access

\- Privilege escalation attacks



\### Evidence

\- docs/audit/2026-01/evidence/10\_device\_guard\_public.json



\### Limitations

Does not detect malicious behavior after execution.



---



\## Control: Hypervisor-Enforced Code Integrity (HVCI / WDAC)



\### Category

Application Control



\### Layer

Execution Boundary



\### Purpose

Prevent execution of unsigned or untrusted code.



\### Risk Mitigated

\- Unauthorized binary execution

\- Living-off-the-land attacks

\- Malware persistence via custom binaries



\### Evidence

\- docs/audit/2026-01/evidence/10\_device\_guard\_public.json



\### Limitations

Does not analyze runtime behavior of allowed binaries.



---



\## Control: BitLocker (TPM-backed)



\### Category

Data Protection



\### Layer

Data-at-Rest Boundary



\### Purpose

Protect data in case of device loss or offline access.



\### Risk Mitigated

\- Offline disk access

\- Data exfiltration via physical theft



\### Evidence

\- docs/audit/2026-01/evidence/11\_bitlocker.json



\### Limitations

Does not protect data after user authentication.



---



\## Control Coverage Summary



This baseline prioritizes:

\- Preventive controls over detective controls

\- Deterministic enforcement over behavioral analysis

\- Platform and execution integrity over user activity monitoring



