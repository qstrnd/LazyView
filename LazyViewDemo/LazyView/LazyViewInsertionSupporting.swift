//
//  LazyViewInsertionSupporting.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-04.
//

import UIKit

protocol LazyViewInsertionSupporting {
    func insert(view: UIView, referenceNeighbor: UIView?)
}

// MARK: - UIKit extensions

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
            insertArrangedSubview(view, at: neighborIndex + 1)
        } else {
            insertArrangedSubview(view, at: 0)
        }
    }

}

