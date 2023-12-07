//
//  LazyViewContainerConfiguration.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-03.
//

import UIKit

/// The configuration that describle the view hierarchy inside the `LazyViewContainer`.
/// It specifies the exact place where `LazyView` needs to be inserted.
///
/// Use special DSL to initialize its instance as in the example below:
/// ```
/// lazyViewContainerConfiguration = LazyViewContainerConfiguration(container: self) {
///     stackView.containing {
///         label
///         nestedLazyStack.containing {
///             button1
///             button2
///         }
///         textField
///     }
/// }
/// ```
/// - Important: With this DSL, you can specify parent-child relationships using `containing` and sibling relationships otherwise.
/// `LazyView` can be nested at any level, but a `UIView` can only be placed at the topmost level, and you'll get a compile-time error if you attempt otherwise.
/// Instances of `UIView` are not inserted into a superview automatically, so you need to set them up preliminarily.
public struct LazyViewContainerConfiguration {
    public typealias ViewId = UUID
    public typealias RelationsDictionary = [ViewId: Relations]

    public struct Relations {
        let superview: Item?
        let referenceNeighbor: Item?

        enum Item {
            case view(UIView)
            case lazyView(LazyViewReference)

            var asUIView: UIView? {
                switch self {
                case .view(let view):
                    return view
                case .lazyView(let lazyView):
                    return lazyView.asUIView
                }
            }
        }
    }

    // MARK: - Properties

    // MARK: Private

    private var relations: RelationsDictionary = [:]

    // MARK: - Methods

    init(relations: [ViewId : Relations]) {
        self.relations = relations
    }
    
    /// Initialize the configuration.
    ///
    /// - Parameters:
    ///   - container: Provide the container so it can be set for every `lazyView` specified in the configuration.
    ///   - builder: DSL for describing view hierarchy. Read more in the documentation for `LazyViewContainerConfiguration`.
    public init(
        container: LazyViewContainer,
        @LazyViewContainerConfigurationBuilder _ builder: () -> LazyViewContainerConfigurationBuilderResult
    ) {
        let result = builder()

        relations = result.relations

        result.lazyViews.forEach { $0.container = container }
    }

    func getRelations(for view: LazyViewReference) -> Relations {
        guard let relations = relations[view.uniqueViewId] else {
            assertionFailure("Failed to get relationships for given view since nothing was found for corresponding id")
            return Relations(superview: nil, referenceNeighbor: nil)
        }

        var referenceNeighbor = relations.referenceNeighbor
        while case let .lazyView(neighborView) = referenceNeighbor, neighborView.asUIView == nil {
            referenceNeighbor = self.relations[neighborView.uniqueViewId]?.referenceNeighbor
        }

        return Relations(
            superview: relations.superview,
            referenceNeighbor: referenceNeighbor
        )
    }

}
