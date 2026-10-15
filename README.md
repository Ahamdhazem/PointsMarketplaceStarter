# Convert Points — iOS trainee assessment

Build the **Convert Points** screen with UIKit, XIBs, Auto Layout and RxSwift/RxCocoa. Timebox: **6–7 hours**, excluding initial package setup and credential verification. The project/scheme retains the name `PointsMarketplaceStarter`; its assessment now covers conversion instead of catalogue/redemption.

## Supplied setup

- iOS 16 deployment target; RxSwift/RxCocoa/RxRelay pinned to **6.10.2**.
- App/scene launch, navigation controller and a blank **Convert Points** controller loaded from its XIB.
- Completed ConversionConfig GET/models and Rx loading/data/error outputs, called from viewDidLoad after token acquisition.
- Complete token-acquisition helper and the reviewer-provided staging configuration. Authentication, encryption and login UI are outside the assessment.
- Wallet backgrounds, selection/lock/conversion/empty-state/success icons, colors and six registered Poppins/Rubik fonts. See [assets](Design/Assets.md).
- Sanitized conversion response fixtures and a test target. Authentication/resource/GET setup tests are supplied; conversion business-rule and POST tests are trainee work.

Open `PointsMarketplaceStarter.xcodeproj`, select the shared scheme and a **named iPhone Simulator**, allow packages to resolve, then Run. You should see a blank screen titled **Convert Points**. At launch, it obtains the token first and then fetches ConversionConfig; the visual UI remains trainee work. No company account, development team or Apple Developer account is needed for simulator use. Simulator signing is disabled. Do not choose a physical phone or `Any iOS Device`.

Before starting the clock, verify the supplied staging account can access **GET ConversionConfig**. Use `AssessmentAuthentication.shared.authorizationHeader()` before constructing requests; it returns the complete Bearer header and obtains/caches `data.access_token` using the supplied API-ready login. See [token helper](Documentation/TokenSetup.md). Do not print or commit access tokens. If staging credentials stop working, ask the reviewer; setup time is excluded.

## Implement

1. Use the supplied **ConversionConfigAPI.swift** GET client and decoded configuration (`viewController.configuration.value`). `loadConversionConfig()` is called from viewDidLoad after token acquisition and can be reused for Retry/refresh. Bind `configuration`, `isLoading` and `loadError` to the UI. Display the balance, all wallets and all conversion options using reusable XIB cells. See [API contract](Documentation/API.md).
2. Follow the [conversion design](Design/ConvertPoints.md) and bundled [layout reference](Design/ConvertPoints.svg). Use wallet background assets mapped by `code`, not backend colors. Display each wallet's API name, balance (three fraction digits) and currency. Long names must wrap without shrinking to unreadable text.
3. Allow exactly one wallet and at most one selected option. Initially prefer a backend `selected` wallet; otherwise use the first. No option is initially selected. Changing wallet retains the option if still valid. Tapping an already-selected option may deselect it.
4. Sort options by `sequence`, then `id`. Use backend option names, cost, amount, currency, confirmation title/message and shortage. Respect `enabled`, `can_convert`, tier/balance eligibility, minimum points, monthly remaining and maximum convertible points. Unavailable options cannot be selected. Exact-balance conversion is valid. No wallets means Convert is disabled.
5. Derive Convert availability reactively. Use RxSwift/RxCocoa for user actions and observable screen state; update UIKit on the main thread and dispose subscriptions correctly. Keep rules/calculations and API work outside cells.
6. Confirm the chosen option and destination wallet before **POST /api/Core/v3.0/loyalty/ConvertPoints**. Send `option_id`, `wallet_id`, and a generated `idempotency_key`. Cancel sends nothing. Validate the confirmed snapshot before submission. Freeze choices and block repeat taps while submitting.
7. Never automatically retry a transaction. Reuse the idempotency key for an explicit retry of the same option/wallet intent; changing intent uses a new key. A timeout can have an unknown outcome; explain uncertainty instead of claiming failure/success or automatically resending.
8. On confirmed success, validate the response against the submitted IDs, apply the returned balance, clear option selection, and show a result using the returned amount/currency/wallet. Reload ConversionConfig once. Preserve the wallet if it remains available. A failed refresh is **separate from successful conversion**; preserve the receipt/balance and disable Convert until a retry loads fresh configuration.
9. On failed conversion, preserve the wallet and option where valid and show a useful API/network message. Handle HTTP errors, authorization failure, API-level errors even with HTTP 200, nullable data, malformed responses and invalid required values. Always end loading/submitting state.
10. Handle initial loading, configuration failures with Retry, empty options and missing wallets. Use `conversion_placeholder_icon` for the empty-options state; hide the Convert action when no options exist.

Use live values, not screenshot numbers. In the supplied API sample, **100 points = 1 JOD**, not the screenshot's 10 JOD. The backend remains authoritative for eligibility and the final conversion result.

Marketplace redemption, History, Current Point navigation, persistence, pagination, login, additional screens and custom number animations are outside the required scope. English only is sufficient. Optional polish after the core works: the SalesApp-style rolling numbers, only on changed values and after the success message is dismissed.

## Acceptance scenarios

| Case | Expected behavior |
| --- | --- |
| Normal config | Backend balance, every wallet and sorted options shown |
| Default wallet | Backend-selected wallet, or first wallet fallback |
| No selected option | Convert disabled |
| Change wallet/option | Correct selection and confirmation; cell reuse adds no duplicate actions |
| Unavailable option | Unselectable with useful shortage/restriction |
| Exact balance | Valid option can convert |
| Feature disabled/tier/minimum/cap | Convert disabled; useful reason |
| Empty options | Correct empty state; no Convert action |
| No wallets | Convert disabled; explain no destination is available |
| Confirmation cancelled | No POST |
| Repeated Confirm taps | One POST only; selection frozen |
| API/HTTP/connection error | Selection preserved; loading ends; useful message |
| Explicit retry of same intent | Same idempotency key; no automatic POST retry |
| Null/invalid data | Error, not successful empty/zero-balance data |
| Successful conversion | Actual result shown, option cleared, balance applied, one GET refresh |
| Failed post-success refresh | Conversion stays successful; Retry refresh without resending POST |

Use staging data or the [fixtures](Fixtures/README.md) to demonstrate cases. Focused automated tests for important rules/request outcomes are expected; exhaustive coverage is not required. Fixture verification must not submit a real staging transaction.

## Suggested time allocation

| Work | Time |
| --- | --- |
| API/design review and architecture | 30 minutes |
| POST models/client and error handling | 75 minutes |
| XIB screen and reusable cells | 105 minutes |
| Rx state, eligibility and selection | 75 minutes |
| Confirmation, submission and refresh | 60 minutes |
| Focused tests, demonstrations and submission | 45–75 minutes |

## Submit

Create your own branch/repository using the access provided by the reviewer; the ZIP is not a Git checkout. Commit and push the source and share the branch/PR link or return a ZIP. Exclude DerivedData, build outputs, personal Xcode state and issued tokens. Do not publish the supplied staging credentials in a public repository.

Add a short `SUBMISSION.md` explaining architecture, tested cases, assumptions and unfinished work. Review focuses on correctness, RxSwift usage, reusable/adaptive XIB UI, networking and error handling. The reviewer rubric is kept outside this trainee ZIP.
