**STRUCT**

# `LazyViewContainerConfiguration`

```swift
public struct LazyViewContainerConfiguration
```

The configuration that describle the view hierarchy inside the `LazyViewContainer`.
It specifies the exact place where `LazyView` needs to be inserted.

Use special DSL to initialize its instance as in the example below:
```
lazyViewContainerConfiguration = LazyViewContainerConfiguration(container: self) {
    stackView.containing {
        label
        nestedLazyStack.containing {
            button1
            button2
        }
        textField
    }
}
```
- Important: With this DSL, you can specify parent-child relationships using `containing` and sibling relationships otherwise.
`LazyView` can be nested at any level, but a `UIView` can only be placed at the topmost level, and you'll get a compile-time error if you attempt otherwise.
Instances of `UIView` are not inserted into a superview automatically, so you need to set them up preliminarily.

## Methods
### `init(container:_:)`

```swift
public init(
    container: LazyViewContainer,
    @LazyViewContainerConfigurationBuilder _ builder: () -> LazyViewContainerConfigurationBuilderResult
)
```

Initialize the configuration.

- Parameters:
  - container: Provide the container so it can be set for every `lazyView` specified in the configuration.
  - builder: DSL for describing view hierarchy. Read more in the documentation for `LazyViewContainerConfiguration`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| container | Provide the container so it can be set for every `lazyView` specified in the configuration. |
| builder | DSL for describing view hierarchy. Read more in the documentation for `LazyViewContainerConfiguration`. |