//
//  LazyViewContainerConfiguration.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-03.
//

import UIKit

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
