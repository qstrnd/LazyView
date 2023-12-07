//
//  LazyViewContainerConfigurationBuilderTests.swift
//  LazyViewTests
//
//  Created by Andy on 2023-12-08.
//

import XCTest
import LazyView

final class LazyViewContainerConfigurationBuilderTests: XCTestCase {

    var containerView: ContainerView!
    var lazyView1: LazyView<UIView> = LazyView<UIView> { UIView() }
    var lazyView2: LazyView<UIView> = LazyView<UIView> { UIView() }
    var lazyView3: LazyView<UIView> = LazyView<UIView> { UIView() }
    var lazyView4: LazyView<UIView> = LazyView<UIView> { UIView() }

    override func setUp() {
        containerView = ContainerView()

        lazyView1 = LazyView<UIView> {
            UIView()
        }

        lazyView2 = LazyView<UIView> {
            UIView()
        }

        lazyView3 = LazyView<UIView> {
            UIView()
        }

        lazyView4 = LazyView<UIView> {
            UIView()
        }
    }

    func testThatLazyViewsAreAddedInCorrectOrder() {
        containerView.lazyViewContainerConfiguration = LazyViewContainerConfiguration(container: containerView) {
            lazyView1
            lazyView2
            lazyView3
            lazyView4
        }

        // order if initialization doesn't matter
        lazyView3.configure(on: true)
        lazyView2.configure(on: true)
        lazyView4.configure(on: true)
        lazyView1.configure(on: true)

        XCTAssertEqual(
            containerView.subviews,
            [
                lazyView1.asUIView!,
                lazyView2.asUIView!,
                lazyView3.asUIView!,
                lazyView4.asUIView!
            ]
        )
    }

    func testThatNestedLazyViewsAreAddedCorrectly() {
        containerView.lazyViewContainerConfiguration = LazyViewContainerConfiguration(container: containerView) {
            lazyView1.containing {
                lazyView2.containing {
                    lazyView3.containing {
                        lazyView4
                    }
                }
            }
        }

        // triggering this lazy view also triggers initialization of superviews
        lazyView4.configure(on: true)

        XCTAssertEqual(containerView.subviews.first!, lazyView1.asUIView!)
        XCTAssertEqual(lazyView1.asUIView!.subviews.first!, lazyView2.asUIView!)
        XCTAssertEqual(lazyView2.asUIView!.subviews.first!, lazyView3.asUIView!)
        XCTAssertEqual(lazyView3.asUIView!.subviews.first!, lazyView4.asUIView!)
    }

    

}
