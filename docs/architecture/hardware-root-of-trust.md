\# Hardware Root of Trust



\## Overview

This system establishes trust at the hardware level using a TPM-backed

security model integrated with Secure Boot and BitLocker.



\## Trusted Components

\- UEFI firmware

\- TPM 2.0 (AMD)

\- Secure Boot key hierarchy



\## TPM Capabilities

The TPM is used for:

\- Secure key storage

\- Disk encryption key protection

\- Boot integrity anchoring



\## Trust Guarantees

\- Cryptographic material is hardware-protected

\- Disk encryption keys are not exposed to the OS

\- Boot integrity is verified before OS execution



\## Attestation Readiness

While remote attestation is not currently implemented,

the platform is technically capable of measured boot and attestation workflows.



\## Limitations

TPM-backed trust does not protect against:

\- Authorized user misuse

\- Runtime exploitation of trusted code



