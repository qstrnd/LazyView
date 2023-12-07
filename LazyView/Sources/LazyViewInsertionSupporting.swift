//
//  LazyViewInsertionSupporting.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-04.
//

import UIKit

/// A protocol that specifies how to insert a lazy view relative to its reference neighbor.
///
/// For `UIView`, the default implementation inserts the lazy view above the reference neighbor.
///
/// For `UIStackView`, the lazy view is inserted as an arranged subview following the index of the reference neighbor.
///
/// You can provide custom insertion behavior for your views.
public protocol LazyViewInsertionSupporting {
    func insert(view: UIView, referenceNeighbor: UIView?)
}

// MARK: - UIKit extensions

extension UIView: LazyViewInsertionSupporting {

    // This method can be overriden for view-specific behavior, that's why @objc modifier is used
    @objc open func insert(view: UIView, referenceNeighbor: UIView?) {
        if let referenceNeighbor = referenceNeighbor {
            insertSubview(view, aboveSubview: referenceNeighbor)
        } else {
            insertSubview(view, at: 0)
        }
    }

}

public extension UIStackView {

    override func insert(view: UIView, referenceNeighbor: UIView?) {
        if let referenceNeighbor = referenceNeighbor,
           let neighborIndex = arrangedSubviews.firstIndex(of: referenceNeighbor)
        {
            insertArrangedSubview(view, at: neighborIndex + 1)
        } else {
            insertArrangedSubview(view, at: 0)
        }
    }

}

