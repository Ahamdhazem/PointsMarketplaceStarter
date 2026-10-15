import XCTest
@testable import PointsMarketplaceStarter

/// Verification of supplied infrastructure; these are not conversion solution tests.
final class AuthenticationHelperTests: XCTestCase {
    private let login = AssessmentAuthentication.LoginValues(
        username: "sample-user", password: "sample-password", deviceToken: "sample-device"
    )

    func testSuppliedTokenSkipsLogin() async throws {
        let stub = Stub()
        let auth = AssessmentAuthentication(providedToken: "provided-token", apiKey: "sample-key",
            login: login, transport: { try await stub.send($0) })
        let header = try await auth.obtainAuthorizationHeader()
        let count = await stub.count
        XCTAssertEqual(header, "Bearer provided-token")
        XCTAssertEqual(count, 0)
    }

    func testConcurrentAcquisitionIsSharedAndCachedAndUsesCorrectRequest() async throws {
        let stub = Stub()
        let auth = AssessmentAuthentication(providedToken: "", apiKey: "sample-key",
            login: login, transport: { try await stub.send($0) })
        async let first = auth.obtainAuthorizationHeader()
        async let second = auth.obtainAuthorizationHeader()
        let headers = try await [first, second]
        let cached = try await auth.obtainAuthorizationHeader()
        XCTAssertEqual(headers, ["Bearer acquired-token", "Bearer acquired-token"])
        XCTAssertEqual(cached, "Bearer acquired-token")
        let count = await stub.count
        let recordedRequest = await stub.lastRequest()
        let request = try XCTUnwrap(recordedRequest)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(request.url, APIConfiguration.tokenObtainURL)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "api-key"), "sample-key")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept-Language"), "en")
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(body["username"] as? String, "sample-user")
        XCTAssertEqual(body["password"] as? String, "sample-password")
        XCTAssertEqual(body["device_token"] as? String, "sample-device")
        XCTAssertEqual((body["query_params"] as? [String: String])?.count, 0)
    }

    func testNearExpiryTokenIsObtainedAgainOnNextCall() async throws {
        let expiry = Date().addingTimeInterval(20).timeIntervalSince1970
        let body = "{\"statusCode\":\"success\",\"data\":{\"access_token\":\"acquired-token\",\"access_token_expiry_time\":\(expiry)}}"
        let stub = Stub(body: body)
        let auth = AssessmentAuthentication(providedToken: "", apiKey: "sample-key",
            login: login, transport: { try await stub.send($0) })
        _ = try await auth.obtainAuthorizationHeader()
        _ = try await auth.obtainAuthorizationHeader()
        let count = await stub.count
        XCTAssertEqual(count, 2, "Tokens near their returned expiry must be reacquired")
    }

    func testMissingConfigurationDoesNotSendRequest() async {
        let stub = Stub()
        let auth = AssessmentAuthentication(providedToken: "", apiKey: "sample-key",
            login: .init(username: "", password: "", deviceToken: ""),
            transport: { try await stub.send($0) })
        do {
            _ = try await auth.obtainAuthorizationHeader()
            XCTFail("Missing configuration must fail")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("reviewer"))
        }
        let count = await stub.count
        XCTAssertEqual(count, 0)
    }

    func testRejectedMalformedEmptyAndExpiredTokensFail() async {
        let examples: [(Int, String)] = [
            (401, "{\"statusCode\":\"error\",\"data\":null,\"error\":{\"message\":\"Invalid test login\"}}"),
            (200, "{\"statusCode\":\"error\",\"data\":null,\"message\":\"Rejected\"}"),
            (200, "not JSON"),
            (200, "{\"statusCode\":\"success\",\"data\":{\"access_token\":\"\"}}"),
            (200, "{\"statusCode\":\"success\",\"data\":{\"access_token\":\"expired\",\"access_token_expiry_time\":1}}")
        ]
        for (status, body) in examples {
            let stub = Stub(status: status, body: body)
            let auth = AssessmentAuthentication(providedToken: "", apiKey: "sample-key",
                login: login, transport: { try await stub.send($0) })
            do {
                _ = try await auth.obtainAuthorizationHeader()
                XCTFail("Invalid token response must fail")
            } catch {
                if status == 401 { XCTAssertEqual(error.localizedDescription, "Invalid test login") }
            }
            let count = await stub.count
            XCTAssertEqual(count, 1, "No automatic retry of rejected login")
        }
    }

    private actor Stub {
        private(set) var count = 0
        private var request: URLRequest?
        let status: Int
        let body: String

        init(status: Int = 200, body: String = "{\"statusCode\":\"success\",\"data\":{\"access_token\":\"acquired-token\",\"access_token_expiry_time\":4102444800}}") {
            self.status = status
            self.body = body
        }

        func lastRequest() -> URLRequest? { request }

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            count += 1
            self.request = request
            try await Task.sleep(nanoseconds: 20_000_000)
            let response = HTTPURLResponse(url: request.url!, statusCode: status,
                httpVersion: nil, headerFields: nil)!
            return (Data(body.utf8), response)
        }
    }
}
