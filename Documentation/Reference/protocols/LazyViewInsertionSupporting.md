**PROTOCOL**

# `LazyViewInsertionSupporting`

```swift
public protocol LazyViewInsertionSupporting
```

A protocol that specifies how to insert a lazy view relative to its reference neighbor.

For `UIView`, the default implementation inserts the lazy view above the reference neighbor.

For `UIStackView`, the lazy view is inserted as an arranged subview following the index of the reference neighbor.

You can provide custom insertion behavior for your views.

## Methods
### `insert(view:referenceNeighbor:)`

```swift
func insert(view: UIView, referenceNeighbor: UIView?)
```
