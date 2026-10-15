# Convert Points API

Use the existing `APIConfiguration` and supplied `AssessmentAuthentication` helper. Authentication and encryption are outside the assessment. Base URL: `https://devapi-salespoint.leading-point.org/api/Core/v3.0/loyalty`.

Both requests use `accept: application/json`, `Accept-Language: en`, `api-key: <configured value>`, and `Authorization: Bearer <access token>`. POST also uses `Content-Type: application/json`.

## Supplied GET implementation

`ConversionConfigAPI.swift` supplies the GET and models. `ConvertPointsViewController.viewDidLoad` calls `loadConversionConfig()`, which waits for the authentication helper before sending the GET. Rx relays `configuration`, `isLoading` and `loadError` are available for trainee UI bindings. Use the same loader for Retry and the post-conversion GET refresh. POST, eligibility/selection and the visual UI remain trainee work.

## GET /ConversionConfig

No request body. Decode the standard envelope (`statusCode`, nullable `data`, `message`, `error`). Never interpret null data or an invalid response as a successful empty screen.

`data` includes balance, eligibility, limits, currency/rate, wallets and conversion options. See `Fixtures/conversion-config-success.json` for the complete supplied contract.

- Balance: `points_balance`.
- Global availability: `enabled`, `can_convert`, `meets_min_tier`, `meets_min_balance`.
- Limits: `min_points`, `max_convertible_points`, `monthly_remaining`. `monthly_remaining: -1` means unlimited; `monthly_cap: 0` means no monthly cap. Zero remaining means no conversions remain.
- Wallets: `id`, `name`, `code`, `balance`, `currency`, `selected`; optional `color` is ignored by the UI. Prefer the backend-selected wallet; otherwise select the first wallet. No wallet means Convert is disabled.
- Options: `id`, `name`, `sequence`, `points`, `currency_amount`, `currency`, `convertible`, `points_needed`, `confirmation_title`, `confirmation_message`. Sort by sequence, then ID. Select at most one option.
- An option must be backend-convertible, pass global eligibility, meet the minimum, and fit both the balance and maximum convertible points. Exact balance is valid. The backend remains authoritative.
- Use API names, rates and amounts. The example API is **100 points = 1 JOD**; do not copy the different rate or balances from the design screenshot.

## POST /ConvertPoints

```json
{
  "option_id": 3,
  "wallet_id": 537,
  "idempotency_key": "a-generated-UUID-for-this-conversion-intent"
}
```

Confirm the chosen option and destination wallet before submission. Freeze selection and prevent repeated submissions. Do not automatically retry a POST. Preserve the same idempotency key for an explicit retry of the same option/wallet intent; a different intent uses a new key.

Success `data` includes `redemption_id`, `name`, `state`, `state_color`, `points_spent`, `currency_amount`, `currency`, `points_balance`, `option_id`, `wallet_id`, `wallet_name`, `settlement_days`. Check the returned option/wallet IDs against the submitted snapshot. See `Fixtures/conversion-success.json`.

After confirmed success, apply the returned balance, clear the selected option, show a result based on the actual response, and request ConversionConfig again. A refresh failure is separate from the successful conversion; preserve its result and disable submission until fresh configuration loads. If adding rolling numbers, begin after the success message is dismissed.

On failure, preserve the selected option/wallet and show the API's useful message. Handle HTTP errors, API-level errors even with HTTP 200, authorization failure, connection failure, null data, malformed JSON and invalid required values. A timeout may have an unknown transaction outcome: no automatic resend and no local claim of success.

## Fixtures

Conversion fixtures cover normal, empty options, no wallets, insufficient/exact balance, disabled conversion, tier restriction, monthly cap, POST success and POST failure. They are sample data; no mock server is included. Fixture-based verification must not submit a real conversion.
