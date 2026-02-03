\# Cryptographic Evidence (v2026.01)



This folder contains cryptographically signed audit evidence.



\## Files



\- evidence\_to\_sign.json  

\- evidence\_to\_sign.json.sha256  

\- evidence\_to\_sign.json.p7s (CMS / PKCS#7 signature)



\## Verification



```bash

openssl cms -verify \\

&nbsp; -in evidence\_to\_sign.json.p7s \\

&nbsp; -inform DER \\

&nbsp; -content evidence\_to\_sign.json \\

&nbsp; -noverify



