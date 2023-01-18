//
//  ParseHookTriggerRequestCombineTests.swift
//  ParseSwift
//
//  Created by Corey Baker on 6/20/22.
//  Copyright © 2022 Parse Community. All rights reserved.
//

#if canImport(Combine)

import Foundation
import XCTest
import Combine
@testable import ParseSwift

class ParseHookTriggerRequestCombineTests: XCTestCase {

    struct User: ParseCloudUser {

        //: These are required by ParseObject
        var objectId: String?
        var createdAt: Date?
        var updatedAt: Date?
        var ACL: ParseACL?
        var originalData: Data?

        // These are required by ParseUser
        var username: String?
        var email: String?
        var emailVerified: Bool?
        var password: String?
        var authData: [String: [String: String]?]?
        var sessionToken: String?

        // Your custom keys
        var customKey: String?

        //: Implement your own version of merge
        func merge(with object: Self) throws -> Self {
            var updated = try mergeParse(with: object)
            if updated.shouldRestoreKey(\.customKey,
                                         original: object) {
                updated.customKey = object.customKey
            }
            return updated
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        guard let url = URL(string: "http://localhost:1337/1") else {
            XCTFail("Should create valid URL")
            return
        }
        try ParseSwift.initialize(applicationId: "applicationId",
                                  clientKey: "clientKey",
                                  primaryKey: "primaryKey",
                                  serverURL: url,
                                  testing: true)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        MockURLProtocol.removeAll()
        #if !os(Linux) && !os(Android) && !os(Windows)
        try KeychainStore.shared.deleteAll()
        #endif
        try ParseStorage.shared.deleteAll()
    }

    func testHydrateUser() throws {
        var subscriptions = Set<AnyCancellable>()
        let expectation1 = XCTestExpectation(description: "Hydrate User")

        let sessionToken = "dog"
        let user = User(objectId: "objectId", sessionToken: sessionToken)
        var userOnServer = user
        userOnServer.createdAt = Date()
        userOnServer.updatedAt = Date()
        var server = userOnServer
        let encoded = try ParseCoding.jsonEncoder().encode(server)
        // Get dates in correct format from ParseDecoding strategy
        server = try ParseCoding.jsonDecoder().decode(User.self, from: encoded)
        MockURLProtocol.mockRequests { _ in
            return MockURLResponse(data: encoded, statusCode: 200)
        }

        let object = User(objectId: "geez")
        let installationId = "cat"
        let triggerRequest = ParseHookTriggerRequest<User, User>(primaryKey: true,
                                                                 user: user,
                                                                 installationId: installationId,
                                                                 ipAddress: "1.1.1.1",
                                                                 headers: ["yolo": "me"],
                                                                 object: object)
        let requestHydrated = ParseHookTriggerRequest<User, User>(primaryKey: true,
                                                                  user: server,
                                                                  installationId: installationId,
                                                                  ipAddress: "1.1.1.1",
                                                                  headers: ["yolo": "me"],
                                                                  object: object)

        let publisher = triggerRequest.hydrateUserPublisher()
            .sink(receiveCompletion: { result in

                if case let .failure(error) = result {
                    XCTFail(error.localizedDescription)
                }
                expectation1.fulfill()

        }, receiveValue: { hydrated in
            XCTAssertEqual(hydrated, requestHydrated)
        })
        publisher.store(in: &subscriptions)
        wait(for: [expectation1], timeout: 20.0)
    }

    func testHydrateUserError() throws {
        var subscriptions = Set<AnyCancellable>()
        let expectation1 = XCTestExpectation(description: "Hydrate User Error")

        let sessionToken = "dog"
        let user = User(objectId: "objectId", sessionToken: sessionToken)
        let server = ParseError(code: .commandUnavailable, message: "no delete")
        let encoded = try ParseCoding.jsonEncoder().encode(server)
        MockURLProtocol.mockRequests { _ in
            return MockURLResponse(data: encoded, statusCode: 200)
        }

        let object = User(objectId: "geez")
        let installationId = "cat"
        let triggerRequest = ParseHookTriggerRequest<User, User>(primaryKey: true,
                                                                 user: user,
                                                                 installationId: installationId,
                                                                 ipAddress: "1.1.1.1",
                                                                 headers: ["yolo": "me"],
                                                                 object: object)
        let publisher = triggerRequest.hydrateUserPublisher()
            .sink(receiveCompletion: { result in

                if case .finished = result {
                    XCTFail("Should have thrown ParseError")
                }
                expectation1.fulfill()

        }, receiveValue: { _ in
            XCTFail("Should have thrown ParseError")
            expectation1.fulfill()
        })
        publisher.store(in: &subscriptions)
        wait(for: [expectation1], timeout: 20.0)
    }
}
#endif
