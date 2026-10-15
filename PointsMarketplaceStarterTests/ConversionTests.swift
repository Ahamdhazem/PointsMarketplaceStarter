import XCTest
@testable import PointsMarketplaceStarter

final class ConversionTests: XCTestCase {
    // TODO: Add meaningful checks for eligibility and exact-balance conversion.
    // TODO: Verify confirmation cancellation, one POST per intent, and idempotency-key reuse.
    // TODO: Verify error/null data, success receipt and refresh failure remain distinct.
}

import Foundation
import RxSwift

final class SuppliedConversionGETTests: XCTestCase {
    func testTokenIsObtainedBeforeGETAndHeadersAndModelMatch() async throws {
        let recorder = RequestRecorder()
        let auth = AssessmentAuthentication(providedToken: "", apiKey: "test-key",
            login: .init(username: "test-user", password: "test-password", deviceToken: "test-device"),
            transport: { request in
                await recorder.record(request)
                let body = Data("{\"statusCode\":\"success\",\"data\":{\"access_token\":\"fixture-token\",\"access_token_expiry_time\":4102444800}}".utf8)
                return (body, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
            })
        let data = try fixture("conversion-config-success")
        let api = ConversionConfigAPI(apiKey: "test-key", authorization: { auth.authorizationHeader() }, transport: { request in
            await recorder.record(request)
            return (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        })
        let config = try await api.fetchConfiguration().value
        let requests = await recorder.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests[0].url, APIConfiguration.tokenObtainURL)
        XCTAssertEqual(requests[1].url?.lastPathComponent, "ConversionConfig")
        XCTAssertEqual(requests[1].httpMethod, "GET")
        XCTAssertNil(requests[1].httpBody)
        XCTAssertEqual(requests[1].value(forHTTPHeaderField: "Authorization"), "Bearer fixture-token")
        XCTAssertEqual(requests[1].value(forHTTPHeaderField: "api-key"), "test-key")
        XCTAssertEqual(requests[1].value(forHTTPHeaderField: "Accept-Language"), "en")
        XCTAssertEqual(config.pointsBalance, 5000)
        XCTAssertEqual(config.wallets.count, 3)
        XCTAssertEqual(config.options.first?.currencyAmount, 1)
    }

    func testTokenFailurePreventsGET() async {
        let recorder = RequestRecorder()
        let api = ConversionConfigAPI(apiKey: "test-key", authorization: { .error(NSError(domain: "Auth", code: 401)) }, transport: { request in
            await recorder.record(request)
            throw NSError(domain: "Unexpected GET", code: 1)
        })
        do { _ = try await api.fetchConfiguration().value; XCTFail("Expected auth failure") } catch {}
        let requests = await recorder.requests
        XCTAssertTrue(requests.isEmpty)
    }

    func testNullDataAndMalformedResponsesFail() async throws {
        for data in [try fixture("conversion-error"), Data("not JSON".utf8)] {
            let api = ConversionConfigAPI(apiKey: "test-key", authorization: { .just("Bearer test-token") }, transport: { request in
                (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
            })
            do { _ = try await api.fetchConfiguration().value; XCTFail("Expected invalid/API error") } catch {}
        }
    }

    func testAuthorizationFailureKeepsUsefulAPIMessage() async throws {
        let api = ConversionConfigAPI(apiKey: "test-key", authorization: { .just("Bearer test-token") }, transport: { request in
            let body = Data("{\"statusCode\":\"error\",\"data\":null,\"error\":{\"message\":\"Token expired\"}}".utf8)
            return (body, HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!)
        })
        do { _ = try await api.fetchConfiguration().value; XCTFail("Expected HTTP error") }
        catch { XCTAssertEqual(error.localizedDescription, "Token expired") }
    }

    private func fixture(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }
    private actor RequestRecorder {
        var requests: [URLRequest] = []
        func record(_ request: URLRequest) { requests.append(request) }
    }
}
