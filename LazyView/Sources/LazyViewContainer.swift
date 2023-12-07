//
//  LazyViewContainer.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-03.
//

import UIKit

/// The container that hosts lazy views and is responsible for their insertion upon request.
///
/// When confirming your `UIView` or `UIViewController` subclass to `LazyViewContainer`,
/// you only need to set up `lazyViewContainerConfiguration`.
public protocol LazyViewContainer: AnyObject {
    var lazyViewContainerConfiguration: LazyViewContainerConfiguration! { get }
    var lazyContainerRootView: UIView { get }

    func insert(lazyView: LazyViewReference)
}

public extension LazyViewContainer {
    func insert(lazyView: LazyViewReference) {
        if lazyView.asUIView == nil {
            lazyView.prepare()
        }

        guard let view = lazyView.asUIView else { return }

        let relations = lazyViewContainerConfiguration.getRelations(for: lazyView)

        // recursively initialize lazy superview
        if case .lazyView(let lazySuperview) = relations.superview {
            insert(lazyView: lazySuperview)
        }

        let superview = relations.superview?.asUIView ?? lazyContainerRootView

        superview.insert(view: view, referenceNeighbor: relations.referenceNeighbor?.asUIView)
    }

}

// MARK: - UIKit extensions

public extension LazyViewContainer where Self: UIView {
    var lazyContainerRootView: UIView {
        self
    }
}

public extension LazyViewContainer where Self: UIViewController {
    var lazyContainerRootView: UIView {
        view
    }
}
