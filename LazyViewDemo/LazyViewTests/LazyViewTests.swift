//
//  LazyViewTests.swift
//  LazyViewTests
//
//  Created by Andy on 2023-12-08.
//

import XCTest
import LazyView

final class LazyViewTests: XCTestCase {

    var sut: LazyView<UILabel>!
    var containerView: ContainerView!

    override func setUp() {
        let lazyView = LazyView {
            UILabel()
        }

        containerView = ContainerView()
        containerView.lazyViewContainerConfiguration = LazyViewContainerConfiguration(container: containerView) {
            lazyView
        }

        sut = lazyView
    }

    // MARK: Init

    func testThatPostInitIsCalledOnlyOnceAfterInitialization() {
        var times = 0

        sut.postInitHandler = { _ in
            times += 1
        }

        sut.configure(on: true)
        sut.configure(on: true)

        XCTAssertEqual(times, 1)
        XCTAssertNotNil(sut.asUIView)
    }

    func testThatPostInitIsNotCalledWhenNoInitializationHappened() {
        var times = 0

        sut.postInitHandler = { _ in
            times += 1
        }

        sut.configure(on: false)

        XCTAssertEqual(times, 0)
        XCTAssertNil(sut.asUIView)
    }

    // MARK: Configuration

    func testThatPostConfigurationIsCalledOnlyOnInitializedView() {
        var times = 0

        sut.postConfigureHandler = { _, _ in
            times += 1
        }

        sut.configure(on: false)
        sut.configure(on: true) // first time postConfigure called
        sut.configure(on: true)
        sut.configure(on: false)

        XCTAssertEqual(times, 3)
        XCTAssertNotNil(sut.asUIView)
    }

    // MARK: Operations

    func testThatOperationIsPerformedOnlyOnInitializedView() {
        var times = 0

        // not called
        sut.performIfVisible { _ in
            times += 1
        }

        sut.configure(on: true)

        // called from now on

        sut.performIfVisible { _ in
            times += 1
        }

        sut.performIfVisible { _ in
            times += 1
        }

        XCTAssertEqual(times, 2)
        XCTAssertNotNil(sut.asUIView)
    }

}
