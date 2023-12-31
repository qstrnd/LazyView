//
//  LazyViewContainerConfigurationBuilder.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-04.
//

import UIKit

// MARK: - ConfigurationBuilderItem

public enum ConfigurationBuilderItem {
    case view(UIView, nested: [ConfigurationBuilderItem])
    case lazyView(LazyViewReference, nested: [ConfigurationBuilderItem])

    var nestedItems: [ConfigurationBuilderItem] {
        switch self {
        case .lazyView(_, nested: let nestedItems):
            return nestedItems
        case .view(_, nested: let nestedItems):
            return nestedItems
        }
    }
}

extension ConfigurationBuilderItem: ViewConfigurationItemConvertible, ViewConfigurationContainedItemConvertible {
    public var configurationItem: ConfigurationBuilderItem { self }
}

// MARK: - ViewConfigurationItemConvertible

public protocol ViewConfigurationItemConvertible {
    var configurationItem: ConfigurationBuilderItem { get }
}

extension UIView: ViewConfigurationItemConvertible {
    public var configurationItem: ConfigurationBuilderItem {
        .view(self, nested: [])
    }

    public func containing(@LazyViewContainerConfigurationContainedBuilder _ nestedComponents: () -> [ConfigurationBuilderItem]) -> ConfigurationBuilderItem {
        .view(self, nested: nestedComponents())
    }
}

extension LazyView: ViewConfigurationItemConvertible {
    public var configurationItem: ConfigurationBuilderItem {
        .lazyView(self, nested: [])
    }

    public func containing(@LazyViewContainerConfigurationContainedBuilder _ nestedComponents: () -> [ConfigurationBuilderItem]) -> ConfigurationBuilderItem {
        .lazyView(self, nested: nestedComponents())
    }
}

// MARK: - ViewConfigurationContainedItemConvertible

public protocol ViewConfigurationContainedItemConvertible {
    var configurationItem: ConfigurationBuilderItem { get }
}

extension LazyView: ViewConfigurationContainedItemConvertible {}

@resultBuilder
public enum LazyViewContainerConfigurationContainedBuilder {
    public static func buildBlock(_ components: ViewConfigurationContainedItemConvertible...) -> [ConfigurationBuilderItem] {
        components.map { $0.configurationItem }
    }

    @available(*, unavailable, message: "Only instances of LazyView can be nested inside `containing` closure")
    public static func buildBlock(_ components: ViewConfigurationItemConvertible...) -> [ConfigurationBuilderItem] {
        fatalError()
    }
}

// MARK: - LazyViewContainerConfigurationBuilder

public typealias LazyViewContainerConfigurationBuilderResult = (relations: LazyViewContainerConfiguration.RelationsDictionary, lazyViews: [LazyViewReference])

@resultBuilder
public enum LazyViewContainerConfigurationBuilder {
    public static func buildBlock(_ components: ViewConfigurationItemConvertible...) -> [ConfigurationBuilderItem] {
        components.map { $0.configurationItem }
    }

    public static func buildFinalResult(_ components: [ConfigurationBuilderItem]) -> LazyViewContainerConfigurationBuilderResult {
        buildKeyedRelations(in: nil, from: components)
    }

    private static func buildKeyedRelations(
        in parentItem: ConfigurationBuilderItem?,
        from nestedItems: [ConfigurationBuilderItem]
    ) -> LazyViewContainerConfigurationBuilderResult {

        var relations: LazyViewContainerConfiguration.RelationsDictionary = [:]
        var lazyViews: [LazyViewReference] = []

        var previousItem: ConfigurationBuilderItem?
        nestedItems.forEach { item in
            if !item.nestedItems.isEmpty {
                let nestedResult = buildKeyedRelations(in: item, from: item.nestedItems)

                lazyViews.append(contentsOf: nestedResult.lazyViews)
                relations.merge(nestedResult.relations, uniquingKeysWith: { (_, new) in
                    new
                })
            }

            if case .lazyView(let lazyView, _) = item {
                lazyViews.append(lazyView)

                relations[lazyView.uniqueViewId] = .init(
                    superview: parentItem.flatMap { configurationRelationsItem(from: $0) },
                    referenceNeighbor: previousItem.flatMap { configurationRelationsItem(from: $0) }
                )
            }

            previousItem = item
        }

        return (relations, lazyViews)
    }

    private static func configurationRelationsItem(from builderItem: ConfigurationBuilderItem) -> LazyViewContainerConfiguration.Relations.Item {
        switch builderItem {
        case .view(let view, nested: _):
            return .view(view)
        case .lazyView(let lazyView, nested: _):
            return .lazyView(lazyView)
        }
    }
}
