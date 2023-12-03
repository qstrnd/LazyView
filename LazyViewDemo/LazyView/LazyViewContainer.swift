//
//  LazyViewContainer.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-03.
//

import UIKit

protocol LazyViewContainer: AnyObject {
    var lazyViewConfiguration: LazyViewContainerConfiguration { get }
    var rootView: UIView { get }

    func insert(lazyView: LazyViewReference)
}

extension LazyViewContainer {
    func insert(lazyView: LazyViewReference) {
        if lazyView.asUIView == nil {
            lazyView.prepare()
        }

        guard let view = lazyView.asUIView else { return }

        let relations = lazyViewConfiguration.getRelations(for: lazyView)

        // recursively initialize lazy superview
        if case .lazyView(let lazySuperview) = relations.superview {
            insert(lazyView: lazySuperview)
        }

        let superview = relations.superview?.asUIView ?? rootView

        superview.insert(view: view, referenceNeighbor: relations.referenceNeighbor?.asUIView)
    }

}

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

protocol LazyViewInsertionSupporting {
    func insert(view: UIView, referenceNeighbor: UIView?)
}

extension UIView: LazyViewInsertionSupporting {
    
    // This method can be overriden for view-specific behavior, that's why it used @objc
    @objc func insert(view: UIView, referenceNeighbor: UIView?) {
        if let referenceNeighbor = referenceNeighbor {
            insertSubview(view, aboveSubview: referenceNeighbor)
        } else {
            insertSubview(view, at: 0)
        }
    }

}

extension UIStackView {

    override func insert(view: UIView, referenceNeighbor: UIView?) {
        if let referenceNeighbor = referenceNeighbor,
           let neighborIndex = arrangedSubviews.firstIndex(of: referenceNeighbor)
        {
            insertArrangedSubview(view, at: neighborIndex)
        } else {
            insertArrangedSubview(view, at: 0)
        }
    }

}
