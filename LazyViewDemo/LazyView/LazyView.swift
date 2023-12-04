//
//  LazyView.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-02.
//

import UIKit

protocol LazyViewReference: AnyObject {
    var uniqueViewId: UUID { get }
    var asUIView: UIView? { get }
    var container: LazyViewContainer? { get set }

    func prepare()
}

final class LazyView<View: UIView>: LazyViewReference {
    typealias Initializer = () -> View
    typealias ViewCondition = (View) -> Bool
    typealias ViewOperation = (View) -> Void
    typealias PostConfiguration = (_ view: View, _ isConfigured: Bool) -> Void


    // MARK: - Properties

    weak var container: LazyViewContainer?
    var postInitHandler: ViewOperation?

    /// Default configuration is provided
    var postConfigureHandler: PostConfiguration? = { view, isConfigured in
        view.isHidden = !isConfigured
    }

    var uniqueViewId = UUID()

    var asUIView: UIView? {
        guard let view = view else { return nil }
        return view as UIView
    }

    /// Get underlying view if it has been already initialized
    var view: View? {
        switch state {
        case .uninitialized:
            return nil
        case .initialized(let view):
            return view
        case .ready(let view):
            return view
        }
    }

    // MARK: Private properties

    private enum State {
        case uninitialized(Initializer)
        case initialized(View)
        case ready(View)
    }

    private var state: State

    // MARK: - Methods

    // MARK: Init

    init(_ initializer: @escaping Initializer) {
        self.state = .uninitialized(initializer)
    }

    func prepare() {
        initialize()
        insertAsSubview()
    }

    // MARK: Configuration

    func configureAsVisible(_ configureOperation: ViewOperation) {
        configure(on: true, configureOperation)
    }

    func configure(on condition: Bool, _ configureOperation: ViewOperation) {
        guard condition else {
            if case .ready(let view) = state {
                postConfigureHandler?(view, false)
            }
            return
        }

        let view: View
        if case .ready(let v) = state {
            view = v
        } else {
            prepare()

            if case .ready(let v) = state {
                view = v
            } else {
                assertionFailure("Failed to initialize and prepare view")
                return
            }
        }

        configureOperation(view)
        postConfigureHandler?(view, true)
    }

    // MARK: Operations

    func performIfVisible(_ operation: ViewOperation) {
        perform(on: { !$0.isHidden }, operation)
    }

    func perform(on condition: ViewCondition, _ operation: ViewOperation) {
        guard case .initialized(let view) = state else {
            return
        }

        guard condition(view) else { return }

        operation(view)
    }

    // MARK: - Private Methods

    private func initialize() {
        guard case .uninitialized(let initializer) = state else {
            return
        }

        let view = initializer()
        state = .initialized(view)

        postInitHandler?(view)
    }

    private func insertAsSubview() {
        guard case .initialized(let view) = state else {
            return
        }

        assert(container != nil, "Failed to lay out view since container is not set")

        container?.insert(lazyView: self)

        state = .ready(view)
    }
}
