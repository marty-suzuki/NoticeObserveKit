# NoticeObserveKit

[![Version](https://img.shields.io/cocoapods/v/NoticeObserveKit.svg?style=flat)](http://cocoapods.org/pods/NoticeObserveKit)
[![License](https://img.shields.io/cocoapods/l/NoticeObserveKit.svg?style=flat)](http://cocoapods.org/pods/NoticeObserveKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/NoticeObserveKit.svg?style=flat)](http://cocoapods.org/pods/NoticeObserveKit)

NoticeObserveKit is type-safe NotificationCenter wrapper.

```swift
// .keyboardWillShow is a static property.
Notice.Center.default.observe(name: .keyboardWillShow) { keyboardInfo in
    // In this case, keyboardInfo is UIKeyboardInfo type.
    // It is inferred from a generic parameter of Notice.Name<Value>.
    print(keyboardInfo)
}
// pool is Notice.ObserverPool.
// If pool is released, Notice.Observes are automatically removed.
.invalidated(by: pool)
```

## Usage

First of all, you need to implement `Notice.Name<T>` like this.
`T` is type of value in notification.userInfo.

```swift
extension Notice.Names {
    static let keyboardWillShow = Notice.Name<UIKeyboardInfo>(UIResponder.keyboardWillShowNotification)
}
```

If you define custom object, you need to implement that with `NoticeUserInfoDecodable` protocol. To confirm this protocol, you must implement `init?(info: [AnyHashable : Any])` and `func dictionaryRepresentation() -> [AnyHashable : Any]`.

```swift
struct UIKeyboardInfo: NoticeUserInfoDecodable {
    let frame: CGRect
    let animationDuration: TimeInterval
    let animationCurve: UIViewAnimationOptions

    init?(info: [AnyHashable : Any]) {
        guard
            let frame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return nil
        }
        self.frame = frame
        self.animationDuration = duration
        self.animationCurve = UIViewAnimationOptions(rawValue: curve)
    }
}
```

Usage for under v0.4.0 is [documents/v0_4_0](./documents/v0_4_0.md).

## Customization

If you can post custom Notification like this.

```swift
extension Notice.Names {
    static let navigationControllerDidShow = Notice.Name<NavigationControllerContent>(name: "navigationControllerDidShow")
}

let content = NavigationControllerContent(viewController: viewController, animated: animated)
Notice.Center.default.post(name: .navigationControllerDidShow, value: content)
```

You can invalidate manually like this.

```swift
let observer = Notice.Center.default.observe(name: .keyboardWillShow) { keyboardInfo in
    print(keyboardInfo)
}
observer.invalidate()
```

You can use vi NotificationCenter.

```swift
NotificationCenter.default.nok.observe(name: .keyboardWillShow) { keyboardInfo in
    print(keyboardInfo)
}
.invalidated(by: pool)
```

## Sample

```swift
import UIKit
import NoticeObserveKit

class ViewController: UIViewController {
    private let searchBar = UISearchBar(frame: .zero)
    private var pool = Notice.ObserverPool()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.titleView = searchBar

        configureObservers()
    }

    private func configureObservers() {
        Notice.Center.default.observe(name: .keyboardWillShow) {
            print("UIKeyboard will show = \($0)")
        }.invalidated(by: pool)

        Notice.Center.default.observe(name: .keyboardWillHide) {
            print("UIKeyboard will hide = \($0)")
        }.invalidated(by: pool)
    }
}
```

## Requirements

- Swift 4.2
- Xcode 10.1 or greater
- iOS 10.0 or greater
- tvOS 10.0 or greater
- macOS 10.10 or greater
- watchOS 3.0 or greater

## Installation

#### CocoaPods

NoticeObserveKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NoticeObserveKit"
```

#### Carthage

If you’re using [Carthage](https://github.com/Carthage/Carthage), simply add
NoticeObserveKit to your `Cartfile`:

```
github "marty-suzuki/NoticeObserveKit"
```

Make sure to add `NoticeObserveKit.framework` to "Linked Frameworks and Libraries" and "copy-frameworks" Build Phases.

## Author

marty-suzuki, s1180183@gmail.com

## License

NoticeObserveKit is available under the MIT license. See the LICENSE file for more info.
