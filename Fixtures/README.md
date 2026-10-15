# Conversion fixtures

These sanitized files use the real API envelope/field names and are bundled in app and test resources. No mock server is included. Inject fixture data in your client/tests; never send a real conversion from fixture-based tests.

| File | Case |
| --- | --- |
| conversion-config-success.json | Normal response, three wallets and sorted options |
| conversion-config-empty.json | Empty options; wallets retained |
| conversion-config-no-wallets.json | No destination wallets |
| conversion-config-insufficient.json | 450-point balance; 500/1000-point options unavailable |
| conversion-config-exact-balance.json | 100-point balance; 100-point option valid |
| conversion-config-monthly-cap.json | Monthly allowance exhausted |
| conversion-config-tier-ineligible.json | Required tier unmet |
| conversion-config-disabled.json | Conversion feature disabled |
| conversion-success.json | Successful POST receipt; 100 points spent, 1 JOD, wallet 537 |
| conversion-error.json | API-level failure with null data |
| unauthorized.json | Authorization failure |
| malformed-response.txt | Invalid JSON |

The success config's balance is 5000; the POST receipt's balance is 4900. Adjust fixtures consistently when testing another option or wallet. Validate eligibility from config rather than relying on screenshot figures. A failed GET after a confirmed POST must not be treated as failed conversion.
