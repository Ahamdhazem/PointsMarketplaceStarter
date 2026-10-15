# Convert Points cases

See [design guidance](ConvertPoints.md) and [available artwork](Assets.md).

1. On load, render API balance and every wallet and option. Prefer the backend-selected wallet; no option is selected initially.
2. Choose one wallet and one available option. Changing either selection updates the confirmation snapshot and total destination amount. Unavailable options stay unselectable.
3. Global restrictions (disabled feature, tier, minimum balance, monthly cap) disable Convert and have a useful reason. Exact balance is valid.
4. Use the option name and API amounts/rates. The supplied contract is 100 points = 1 JOD; screenshot values are illustrative.
5. Confirm the option and wallet. Cancel makes no POST. During submission, freeze selections and prevent double taps.
6. A confirmed success updates balance, clears the option, shows a dynamic receipt, and reloads ConversionConfig. A failed refresh does not erase or relabel that success.
7. Show an empty-options state using conversion_placeholder_icon. No wallets disables conversion. Initial/config errors support Retry.
8. Explicit same-intent retries reuse an idempotency key; never auto-retry transactions. Report unknown timeout outcomes clearly.

Optional polish: match SalesApp's digit-reel balance animation; only changed values roll and only after the success message is dismissed. This is outside the 6–7 hour core assessment.
