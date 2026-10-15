# Using the supplied authentication helper

**Ready to use:** the reviewer has already configured the API key, API-ready username/password, and device token in `Configuration/App.xcconfig`. Do not enter credentials or paste an access token. No Postman/cURL setup is required.

`AssessmentAuthentication.swift` implements the complete token obtain API request. Authentication implementation and token renewal are outside your assessment; you only use the supplied helper in your conversion API client.

## Integration

```swift
AssessmentAuthentication.shared.authorizationHeader()
    .subscribe(onSuccess: { authorization in
        // Construct your conversion request here.
        // request.setValue(authorization, forHTTPHeaderField: "Authorization")
        // request.setValue(APIConfiguration.apiKey, forHTTPHeaderField: "api-key")
        // Add the other documented headers, then perform your GET or POST.
    }, onFailure: { error in
        // End loading and show an appropriate message.
    })
    .disposed(by: disposeBag)
```

The emitted value already includes `Bearer `; do not prepend it again. You can compose this Single with your request using RxSwift instead of subscribing directly. Delivery is on the main scheduler. The helper does not implement either conversion endpoint.

## What is already supplied

- POST `https://devapi-salespoint.leading-point.org/api/Core/v3.0/auth/token/obtain` with `accept: application/json`, `Accept-Language: en`, the configured `api-key`, and `Content-Type: application/json`.
- JSON body containing the configured `device_token`, `password`, and `username`, plus `query_params: {}`. Values are sent unchanged; no encryption or push-registration code is needed.
- Validation of the HTTP response and business status, extraction of `data.access_token`, and errors for failed, malformed, empty, or expired-token responses.
- In-memory token caching, shared concurrent acquisition, and re-acquisition on the next helper call when the returned `access_token_expiry_time` is within 30 seconds. The helper does not automatically replay a conversion request or redemption.
- Five supplied infrastructure tests in `AuthenticationHelperTests.swift`; your conversion tests remain to be written.

The token comes from the JSON response body, **`data.access_token`**, not a response header. `refresh_token` is not used. The blank starter does not obtain a token until your API client calls the helper.

If acquisition or conversion authorization fails, show a useful error and end loading. Ask the reviewer to check test-account access if needed. No automatic login/retry interceptor is required. Credential issues are outside assessment time.

`Secrets.example.xcconfig` is an optional override template for the reviewer; you do not need to copy it. An explicitly configured `APP_BEARER_TOKEN` takes precedence over acquisition, but the distributed starter leaves it empty so the supplied helper obtains tokens.
