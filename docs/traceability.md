\# Security Control Traceability Matrix



| Control                         | Evidence Source                | Assertion | Score Weight |

|--------------------------------|--------------------------------|-----------|--------------|

| TPM present and ready           | Get-Tpm                        | PASS      | 20           |

| Secure Boot enabled             | Confirm-SecureBootUEFI         | PASS      | 15           |

| VBS enabled                     | Win32\_DeviceGuard              | PASS      | 20           |

| HVCI running                    | SecurityServicesRunning        | PASS      | 15           |

| BitLocker enabled (OS volume)   | Get-BitLockerVolume            | PASS      | 20           |

| Firewall enabled (all profiles) | Get-NetFirewallProfile         | PASS      | 10           |



All controls are evaluated deterministically and included

in the posture scoring algorithm.



