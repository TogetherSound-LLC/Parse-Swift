//
//  BatchUtilsTests.swift
//  ParseSwift
//
//  Created by Corey Baker on 1/2/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import XCTest
@testable import ParseSwift

class BatchUtilsTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testSplitArrayLessSegments() throws {
        let array = [1, 2]
        let splitArray = BatchUtils.splitArray(array, valuesPerSegment: 3)
        guard let firstSplit = splitArray.first else {
            XCTFail("Should have a first item in the array")
            return
        }
        XCTAssertEqual(splitArray.count, 1)
        XCTAssertEqual(firstSplit, array)
    }

    func testSplitArrayExactSegments() throws {
        let array = [1, 2]
        let splitArray = BatchUtils.splitArray(array, valuesPerSegment: 2)
        guard let firstSplit = splitArray.first else {
            XCTFail("Should have a first item in the array")
            return
        }
        XCTAssertEqual(splitArray.count, 1)
        XCTAssertEqual(firstSplit, array)
    }

    func testSplitArrayMoreSegments() throws {
        let array = [1, 2]
        let splitArray = BatchUtils.splitArray(array, valuesPerSegment: 1)
        guard let firstSplit = splitArray.first,
              let lastSplit = splitArray.last else {
            XCTFail("Should have a first item in the array")
            return
        }
        XCTAssertEqual(splitArray.count, 2)
        XCTAssertEqual(firstSplit, [1])
        XCTAssertEqual(lastSplit, [2])
    }

    func testSplitArrayEvenMoreSegments() throws {
        let array = [1, 2, 3, 4, 5]
        let splitArray = BatchUtils.splitArray(array, valuesPerSegment: 1)
        guard let firstSplit = splitArray.first,
              let lastSplit = splitArray.last else {
            XCTFail("Should have a first item in the array")
            return
        }
        XCTAssertEqual(splitArray.count, 5)
        XCTAssertEqual(firstSplit, [1])
        XCTAssertEqual(lastSplit, [5])

        guard splitArray.count == 5 else {
            XCTFail("Should have 5 items")
            return
        }

        XCTAssertEqual(splitArray[1], [2])
        XCTAssertEqual(splitArray[2], [3])
        XCTAssertEqual(splitArray[3], [4])
    }

    func testSplitArrayComplexSegments() throws {
        let array = [1, 2, 3, 4, 5, 6, 7]
        let splitArray = BatchUtils.splitArray(array, valuesPerSegment: 2)
        guard let firstSplit = splitArray.first,
              let lastSplit = splitArray.last else {
            XCTFail("Should have a first item in the array")
            return
        }
        XCTAssertEqual(splitArray.count, 4)
        XCTAssertEqual(firstSplit, [1, 2])
        XCTAssertEqual(lastSplit, [7])

        guard splitArray.count == 4 else {
            XCTFail("Should have 4 items")
            return
        }

        XCTAssertEqual(splitArray[1], [3, 4])
        XCTAssertEqual(splitArray[2], [5, 6])
    }
}
