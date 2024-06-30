# NoticeObserveKit

[![Version](https://img.shields.io/cocoapods/v/NoticeObserveKit.svg?style=flat)](http://cocoapods.org/pods/NoticeObserveKit)
[![License](https://img.shields.io/cocoapods/l/NoticeObserveKit.svg?style=flat)](http://cocoapods.org/pods/NoticeObserveKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/NoticeObserveKit.svg?style=flat)](http://cocoapods.org/pods/NoticeObserveKit)

NoticeObserveKit is type-safe NotificationCenter wrapper.

Swift Concurrency (since macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0)

```swift
Task {
    // .keyboardWillShow is a static property.
    for try await keyboardInfo in NotificationCenter.default.nok.notifications(named: .keyboardWillShow) { 
        // In this case, keyboardInfo is UIKeyboardInfo type.
        // It is inferred from a generic parameter of Notice.Name<Value>.
        print(keyboardInfo)
    }
}
```

Combine (since macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0)

```swift
// .keyboardWillShow is a static property.
NotificationCenter.default.nok.publisher(for: .keyboardWillShow)
    .sink(
        receiveCompletion: { _ in },
        receiveValue: { keyboardInfo in
            // In this case, keyboardInfo is UIKeyboardInfo type.
            // It is inferred from a generic parameter of Notice.Name<Value>.
            print(keyboardInfo)
        }
    )
    .store(in: &cancellables)
```

NoticeObserveKit original

```swift
// .keyboardWillShow is a static property.
NotificationCenter.default.nok.observe(name: .keyboardWillShow) { keyboardInfo in
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
    static let keyboardWillShow = Notice.Name<UIKeyboardInfo>(
        UIResponder.keyboardWillShowNotification
    ) { userInfo in
        // Implementing decode is only required if you want to use an already defined Notification.Name (e.g. UIResponder.keyboardWillShowNotification).
        guard
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt
        else {
            throw DecodeError()
        }

        return UIKeyboardInfo(
            frame: frame,
            animationDuration: duration,
            animationCurve: UIViewAnimationOptions(rawValue: curve)
        )
    }
}
```

## Customization

If you can post custom Notification like this.

```swift
extension Notice.Names {
    // If you define your own custom Notification.Name, no implementation of decode is required.
    static let navigationControllerDidShow = Notice.Name<NavigationControllerContent>(name: "navigationControllerDidShow")
}

let content = NavigationControllerContent(viewController: viewController, animated: animated)
NotificationCenter.default.nok.post(name: .navigationControllerDidShow, value: content)
```

You can invalidate manually like this.

```swift
let observer = NotificationCenter.default.nok.observe(name: .keyboardWillShow) { keyboardInfo in
    print(keyboardInfo)
}
observer.invalidate()
```

## Sample

```swift
import UIKit
import NoticeObserveKit

class ViewController: UIViewController {
    private let searchBar = UISearchBar(frame: .zero)
    private lazy var keyboardNotificationTasks: [Task<Void, Error>] = [
        Task {
            for try await value in NotificationCenter.default.nok.notifications(named: .keyboardWillShow) {
                print("UIKeyboard will show = \(value)")
            }
        },
        Task {
            for try await value in NotificationCenter.default.nok.notifications(named: .keyboardWillHide) {
                print("UIKeyboard will hide = \(value)")
            }
        }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.titleView = searchBar

        configureObservers()
    }

    private func configureObservers() {
        _ = keyboardNotificationTasks
    }
}
```

## Requirements

- Swift 5
- Xcode 15.0 or greater
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
