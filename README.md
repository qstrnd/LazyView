# LazyView

[![Version](https://img.shields.io/cocoapods/v/LazyView.svg?style=flat)](https://cocoapods.org/pods/LazyView)
[![License](https://img.shields.io/cocoapods/l/LazyView.svg?style=flat)](https://cocoapods.org/pods/LazyView)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![Platform](https://img.shields.io/cocoapods/p/LazyView.svg?style=flat)](https://cocoapods.org/pods/LazyView)

A lightweight wrapper for lazily initializing UIViews.

The library provides a simple API to control how and when your views should be initialized. It enables you to easily defer or avoid initializing heavy subviews, which can improve the overall performance of your app.

## Quick Start

Clone the repo and run `pod install` from the LazyViewDemo directory to explore the demo. You can also refer to [Documentation](Documentation/Reference/).

Following the demo as example, what you need is:

1. Confirm your view or view controller to `LazyViewContainer`:

```swift
final class ViewControllerWithLazySubviews: UIViewController, LazyViewContainer { ... }
```

2. Define your lazy views:

```swift
private let textField: LazyView<UITextField>
```

3. Set up these properties with initializer for underlying views:

```swift
textField = LazyView {
    UITextField()
}
```

4. Describe your lazy view hierarchy:

```swift
// Initialize container configuration using DSL.
// Stack view contains label, nestedLazyStack and textField;
// nestedLazyStack contains buttons.
// The order is important! Read more in the docs foLazyViewContainerConfiguration

lazyViewContainerConfiguration = LazyViewContainerConfigurati(container: self) {
    stackView.containing {
        label
        nestedLazyStack.containing {
            button1
            button2
            button3
            button4
        }
        textField
    }
}
```

5. Setup `postInitHandler` if needed:

```swift
 textField.postInitHandler = { [weak self] textField in
    guard let self else { return }
    textField.delegate = self
}
```

The setup is done! Now, when you actually need the view, run the code to configure it based on a condition. The first configuration is preceded by initialization.

```swift
textField.configure(on: configuration.showTextField) { textField in
    // you can set up your view with corresponding model here
    // this code will be executed only if condition is true
}
```

Initialization of the view's dependencies (if it's nested) and figuring out its position in a superview relative to other views is handled for you based on what you described in `LazyViewContainerConfigurati` 🪄

You also have the ability to perform some actions only when the view is initialized. For example:

```swift
textField.performIfVisible { _ in
    // do something
}
```

Refer to the documentation or source code for further information.

## Installation

LazyView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LazyView'
```

To manually clone the repo, run this command:

```bash
git clone https://github.com/qstrnd/dotfiles
```

## Requirements

- Swift 5.0+
- Xcode 14.0+
- iOS 13+

## Contact

Follow and contact me on Twitter [@qstrnd](https://twitter.com/qstrnd) or via email `a.iakovlev@proton.me`.

## License

LazyView is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
