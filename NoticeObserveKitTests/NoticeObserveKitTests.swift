//
//  NoticeObserveKitTests.swift
//  NoticeObserveKitTests
//
//  Created by marty-suzuki on 2019/02/16.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

import XCTest
@testable import NoticeObserveKit

class NoticeObserveKitTests: XCTestCase {

    func testSingleCenter() {
        let name = "test-notification"
        let noticeName = Notice.Name<Int>(name: name)
        let center = Notice.Center()
        let intValue = Int.random(in: Int.min...Int.max)

        var called = false
        let observer = center.observe(name: noticeName) { receiving in
            XCTAssertEqual(intValue, receiving)
            called = true
        }

        center.post(name: noticeName, with: intValue)

        XCTAssertTrue(called)

        observer.invalidate()
    }

    func testMultipleCenter() {
        let name = "test-notification"
        let noticeName = Notice.Name<Int>(name: name)

        let center1 = Notice.Center()
        let center2 = Notice.Center()
        let intValue = Int.random(in: Int.min...Int.max)

        var called1 = false
        let observer1 = center1.observe(name: noticeName) { receiving in
            XCTAssertEqual(intValue, receiving)
            called1 = true
        }

        var called2 = false
        let observer2 = center2.observe(name: noticeName) { receiving in
            called2 = true
        }

        center1.post(name: noticeName, with: intValue)

        XCTAssertTrue(called1)
        XCTAssertFalse(called2)

        observer1.invalidate()
        observer2.invalidate()
    }

    func testSingleCenterAndMultipleName() {
        let noticeName1 = Notice.Name<Int>(name: "test-notification1")
        let noticeName2 = Notice.Name<Int>(name: "test-notification2")

        let center = Notice.Center()
        let intValue = Int.random(in: Int.min...Int.max)

        var calledCount: Int = 0
        let observer = center.observe(name: noticeName1) { receiving in
            XCTAssertEqual(intValue, receiving)
            calledCount += 1
        }

        center.post(name: noticeName1, with: intValue)
        center.post(name: noticeName2, with: intValue)

        XCTAssertEqual(calledCount, 1)

        observer.invalidate()
    }

    func testInvalidate() {
        let name = "test-notification"
        let noticeName = Notice.Name<Int>(name: name)
        let center = Notice.Center()
        let intValue = Int.random(in: Int.min...Int.max)

        var calledCount: Int = 0
        let observer = center.observe(name: noticeName) { _ in
            calledCount += 1
        }

        center.post(name: noticeName, with: intValue)
        observer.invalidate()
        center.post(name: noticeName, with: intValue)

        XCTAssertEqual(calledCount, 1)
    }

    func testInvalidatedByObserverPool() {
        let name = "test-notification"
        let noticeName = Notice.Name<Int>(name: name)
        let center = Notice.Center()
        let intValue = Int.random(in: Int.min...Int.max)

        var pool = Notice.ObserverPool()
        var calledCount: Int = 0
        center.observe(name: noticeName) { _ in
            calledCount += 1
        }.invalidated(by: pool)

        center.post(name: noticeName, with: intValue)
        pool = Notice.ObserverPool()
        center.post(name: noticeName, with: intValue)

        XCTAssertEqual(calledCount, 1)
    }
}
