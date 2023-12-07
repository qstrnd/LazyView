//
//  LazyView.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-02.
//

import UIKit

public protocol LazyViewReference: AnyObject {
    var uniqueViewId: UUID { get }
    var asUIView: UIView? { get }
    var container: LazyViewContainer? { get set }

    func prepare()
}

/// A wrapper for lazily initializing any view. It's initialized with a closure that's executed when the view needs to be configured for the first time.
///
/// Trigger view configuration by calling 
/// ```
/// configure(on condition: Bool, _ configureOperation: ViewOperation)
/// ```
/// and it's relatives.
///
/// Use `postInitHandler` for any configuration that needs to be done only once immediately after initialization (like setting your view's `delegate`).
///
/// Use `postConfigureHandler` for tweaking any post-configuration logic if the view has been initialized. 
/// The default handler sets `isHidden` to true if configuration condition is not met and vice versa.
///
/// - Important: There's no compile-time check of what you put inside as an underlying view since your views can be referenced as protocols.
/// Nevertheless, keep in mind that attempting to insert an object that is not a UIView into the view hierarchy will trigger an `assertionFailure`.
public final class LazyView<View>: LazyViewReference {
    public typealias Initializer = () -> View
    public typealias ViewCondition = (View) -> Bool
    public typealias ViewOperation = (View) -> Void
    public typealias PostConfiguration = (_ view: View, _ isConfigured: Bool) -> Void

    // MARK: - Properties
    
    /// The container for the lazy view that is responsible for adding the view to the view hierarchy.
    /// - Note: Do not set it manually! Instead, reference your lazy view wrapper when initializing `LazyViewContainerConfiguration`
    public weak var container: LazyViewContainer?

    /// Handler that is called only once immediately after initialization. Use it for additonal configuration of your view like setting its `delegate`
    /// - Warning: Do not forget to reference `self` as `weak` to avoid a reference cycle
    public var postInitHandler: ViewOperation?

    /// Handler for any post configuration
    ///
    /// Namely, the handler is called in two scenarios:
    /// 1. The view is successfully configured (the configuration condition is met).
    /// 2. The view is not configured because the condition is not met, but it had already been initialized. In this case, you may want to add some cleanup logic.
    ///
    /// - Note: If you don't set this property, a default handler is provided. The default handler sets `isHidden` to true if the configuration condition is not met and vice versa.
    /// - Warning: Do not forget to reference `self` as `weak` to avoid a reference cycle.
    public var postConfigureHandler: PostConfiguration?
    
    /// The id of the lazy used to match the view with its configuration in `LazyViewContainerConfiguration`
    public let uniqueViewId = UUID()
    
    /// Get the underlying view as `UIView`
    /// - Note: This property returns the underlying view only if it has been initialized. If you want to force initialize the view, use `configureAsVisible` instead.
    public var asUIView: UIView? {
        guard let view = view else { return nil }
        guard let uiView = view as? UIView else {
            assertionFailure("Failed to cast the underlying view to UIView")
            return nil
        }
        return uiView
    }

    /// Get the underlying view
    /// - Note: This property returns the underlying view only if it has been initialized. If you want to force initialize the view, use `configureAsVisible` instead.
    public var view: View? {
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
    
    /// Initialize the lazy view with a closure
    ///
    /// - Parameter initializer: The closure that return an initialized `View`.
    /// - Warning: Do not forget to reference `self` as `weak` to avoid a reference cycle.
    /// - Tip: A recommended approach is to avoid referencing `self` in the initializer to prevent the error `self used before super.init call`.
    /// Instead, reference `self` in `postConfigureHandler` that is set after finishing your container's initialization.
    /// This way, you can avoid the necessity of using force unwrapping for `LazyView` properties.
    public init(_ initializer: @escaping Initializer) {
        self.state = .uninitialized(initializer)

        postConfigureHandler = { [unowned self] _, isConfigured in
            guard let view = self.asUIView else { return }
            view.isHidden = !isConfigured
        }
    }
    
    /// Prepare the underlying view for usage by initializing and inserting it into the view hierarchy.
    /// Avoid calling this method manually; instead, use the `configure(...)` family of methods.
    public func prepare() {
        initialize()
        insertAsSubview()
    }

    // MARK: Configuration

    /// Use this variation of `configure` method when you don't need to provide variable configuration logic for different states of your view.
    public func configure(on condition: Bool) {
        configure(on: condition, { _ in })
    }
    
    /// Configure the underlying view if condition is met.
    ///
    /// - Parameters:
    ///   - condition: The condition that determines if the view needs to be configured
    ///   - configureOperation: Configuration closure used to update your view with the appropriate state.
    ///
    /// - Note: This method triggers view initialization before the first configuration when the specified condition is met.
    /// After initialization, `postConfigureHandler` is called on every configuration attempt.
    public func configure(on condition: Bool = true, _ configureOperation: ViewOperation) {
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
    
    /// Perform an operation on the underlying view if it is visible (and has been initialized).
    ///
    /// - Parameter operation: The operation on the view
    public func performIfVisible(_ operation: ViewOperation) {
        perform(
            on: { _ in
                guard let view = self.asUIView else { return false }
                return !view.isHidden
            },
            operation
        )
    }
    
    /// Perform an operation on the underlying view if it has been initialized.
    ///
    /// - Parameters:
    ///   - condition: The condition that must be met for the operation to be performed.
    ///   - operation: The operation on the view.
    public func perform(on condition: ViewCondition, _ operation: ViewOperation) {
        guard case .ready(let view) = state else {
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
