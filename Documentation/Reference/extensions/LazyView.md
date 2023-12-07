**EXTENSION**

# `LazyView`
```swift
extension LazyView: ViewConfigurationItemConvertible
```

## Properties
### `configurationItem`

```swift
public var configurationItem: ConfigurationBuilderItem
```

## Methods
### `containing(_:)`

```swift
public func containing(@LazyViewContainerConfigurationContainedBuilder _ nestedComponents: () -> [ConfigurationBuilderItem]) -> ConfigurationBuilderItem
```
