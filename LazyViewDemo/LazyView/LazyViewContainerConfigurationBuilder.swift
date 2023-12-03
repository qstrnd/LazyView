//
//  LazyViewContainerConfigurationBuilder.swift
//  LazyViewDemo
//
//  Created by Andy on 2023-12-04.
//

import UIKit

// MARK: - ContainerItem

enum ConfigurationBuilderItem {
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

protocol ViewConfigurationItemConvertible {
    var configurationItem: ConfigurationBuilderItem { get }
}

extension ConfigurationBuilderItem: ViewConfigurationItemConvertible {
    var configurationItem: ConfigurationBuilderItem { self }
}

extension UIView: ViewConfigurationItemConvertible {
    var configurationItem: ConfigurationBuilderItem {
        .view(self, nested: [])
    }

    func containing(@LazyViewContainerConfigurationTransientBuilder _ nestedComponents: () -> [ConfigurationBuilderItem]) -> ConfigurationBuilderItem {
        .view(self, nested: nestedComponents())
    }
}

extension LazyView: ViewConfigurationItemConvertible {
    var configurationItem: ConfigurationBuilderItem {
        .lazyView(self, nested: [])
    }

    func containing(@LazyViewContainerConfigurationTransientBuilder _ nestedComponents: () -> [ConfigurationBuilderItem]) -> ConfigurationBuilderItem {
        .lazyView(self, nested: nestedComponents())
    }
}

@resultBuilder
enum LazyViewContainerConfigurationTransientBuilder {
    static func buildBlock(_ components: ViewConfigurationItemConvertible...) -> [ConfigurationBuilderItem] {
        components.map { $0.configurationItem }
    }
}

@resultBuilder
enum LazyViewContainerConfigurationBuilder {
    static func buildBlock(_ components: ViewConfigurationItemConvertible...) -> [ConfigurationBuilderItem] {
        components.map { $0.configurationItem }
    }

    static func buildFinalResult(_ components: [ConfigurationBuilderItem]) -> LazyViewContainerConfiguration.RelationsDictionary {
        buildKeyedRelations(in: nil, from: components)
    }

    private static func buildKeyedRelations(in parentItem: ConfigurationBuilderItem?, from nestedItems: [ConfigurationBuilderItem]) -> LazyViewContainerConfiguration.RelationsDictionary {
        var result: LazyViewContainerConfiguration.RelationsDictionary = [:]

        var previousItem: ConfigurationBuilderItem?
        nestedItems.forEach { item in
            if !item.nestedItems.isEmpty {
                let nestedResult = buildKeyedRelations(in: item, from: item.nestedItems)
                result.merge(nestedResult, uniquingKeysWith: { (_, new) in
                    new
                })
            }

            if case .lazyView(let lazyViewReference, _) = item {
                result[lazyViewReference.uniqueViewId] = .init(
                    superview: parentItem.flatMap { configurationRelationsItem(from: $0) },
                    referenceNeighbor: previousItem.flatMap { configurationRelationsItem(from: $0) }
                )
            }

            previousItem = item
        }

        return result
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
