//
//  LazyViewContainer.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-03.
//

import UIKit

protocol LazyViewContainer: AnyObject {
    var lazyViewContainerConfiguration: LazyViewContainerConfiguration! { get }
    var rootView: UIView { get }

    func insert(lazyView: LazyViewReference)
}

extension LazyViewContainer {
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

        let superview = relations.superview?.asUIView ?? rootView

        superview.insert(view: view, referenceNeighbor: relations.referenceNeighbor?.asUIView)
    }

}

// MARK: - UIKit extensions

extension LazyViewContainer where Self: UIView {
    var rootView: UIView {
        self
    }
}

extension LazyViewContainer where Self: UIViewController {
    var rootView: UIView {
        view
    }
}
