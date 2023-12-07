**PROTOCOL**

# `LazyViewContainer`

```swift
public protocol LazyViewContainer: AnyObject
```

The container that hosts lazy views and is responsible for their insertion upon request.

When confirming your `UIView` or `UIViewController` subclass to `LazyViewContainer`,
you only need to set up `lazyViewContainerConfiguration`.

## Properties
### `lazyViewContainerConfiguration`

```swift
var lazyViewContainerConfiguration: LazyViewContainerConfiguration!
```

### `lazyContainerRootView`

```swift
var lazyContainerRootView: UIView
```

## Methods
### `insert(lazyView:)`

```swift
func insert(lazyView: LazyViewReference)
```
