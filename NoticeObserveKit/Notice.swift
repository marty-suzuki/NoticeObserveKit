//
//  Notice.swift
//  NoticeObserveKit
//
//  Created by marty-suzuki on 2019/01/25.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

// MARK: - Notice definition

public enum Notice {

    public final class Center {

        @available(iOS, deprecated: 10, renamed: "NotificationCenter.default.nok")
        @available(watchOS, deprecated: 3, renamed: "NotificationCenter.default.nok")
        @available(tvOS, deprecated: 10, renamed: "NotificationCenter.default.nok")
        @available(OSX, deprecated: 10.10, renamed: "NotificationCenter.default.nok")
        public static let `default` = Center(center: .default)

        let center: NotificationCenter

        init(center: NotificationCenter) {
            self.center = center
        }

        public convenience init() {
            self.init(center: .init())
        }
    }

    public class Names {
        fileprivate init() {}
    }

    public final class Name<Value>: Names {

        let raw: Notification.Name
        let decode: (([AnyHashable: Any]) throws -> Value)?

        public convenience init(name: String) {
            self.init(name: Notification.Name(name), decode: nil)
        }

        public convenience init(
            _ name: Notification.Name,
            decode: @escaping ([AnyHashable: Any]) throws -> Value
        ) {
            self.init(name: name, decode: decode)
        }

        internal init(
            name: Notification.Name,
            decode: (([AnyHashable: Any]) throws -> Value)?
        ) {
            self.raw = name
            self.decode = decode
            super.init()
        }
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public final class Observer {

        private(set) weak var center: NotificationCenter?
        let raw: NSObjectProtocol

        init(center: NotificationCenter, raw: NSObjectProtocol) {
            self.center = center
            self.raw = raw
        }
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public class ObserverPool {
        private(set) var observers: [Observer] = []
        private(set) var mutex: pthread_mutex_t = pthread_mutex_t()

        public init() {
            pthread_mutex_init(&mutex, nil)
        }

        deinit {
            pthread_mutex_lock(&mutex)
            observers.forEach {
                $0.invalidate()
            }
            observers.removeAll()
            pthread_mutex_unlock(&mutex)
            pthread_mutex_destroy(&mutex)
        }

        func adding(_ observer: Observer) {
            pthread_mutex_lock(&mutex)
            observers = Array([observers, [observer]].joined())
            pthread_mutex_unlock(&mutex)
        }
    }

    public struct InvalidUserInfError: Swift.Error {
        public let message: String
        public let userInfo: [AnyHashable: Any]?
    }
}

extension Notice.Name where Value == Void {

    public convenience init(_ name: Notification.Name) {
        self.init(name: name, decode: nil)
    }
}

// MARK: - Notice.Center

extension Notice.Center {

    enum Const {
        static let infoKey = "noice-info-key"
    }

    public func post<Value>(name: Notice.Name<Value>, with value: Value, from object: Any? = nil) {
        let userInfo: [AnyHashable : Any] = [Const.infoKey : value]
        center.post(name: name.raw, object: object, userInfo: userInfo)
    }

    public func post(name: Notice.Name<Void>, from object: Any? = nil) {
        center.post(name: name.raw, object: object, userInfo: nil)
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public func observe<Value>(name: Notice.Name<Value>,
                               object: Any? = nil,
                               queue: OperationQueue? = nil,
                               using: @escaping (Value) -> Void) -> Notice.Observer {
        let observer = center.addObserver(forName: name.raw, object: object, queue: queue) { notification in
            guard let userInfo = notification.userInfo else {
                return
            }

            if let decode = name.decode, let value = try? decode(userInfo) {
                using(value)
            } else if let value = notification.userInfo?[Const.infoKey] as? Value {
                using(value)
            }
        }
        return Notice.Observer(center: center, raw: observer)
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public func observe(
        name: Notice.Name<Void>,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        using: @escaping () -> Void
    ) -> Notice.Observer {
        let observer = center.addObserver(forName: name.raw, object: object, queue: queue) { _ in
            using()
        }
        return Notice.Observer(center: center, raw: observer)
    }

#if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func publisher<Value>(
        for name: Notice.Name<Value>,
        object: AnyObject? = nil
    ) -> AnyPublisher<Value, Notice.InvalidUserInfError> {
        center
            .publisher(for: name.raw, object: object)
            .setFailureType(to: Notice.InvalidUserInfError.self)
            .flatMap { notification -> AnyPublisher<Value, Notice.InvalidUserInfError> in
                guard let userInfo = notification.userInfo else {
                    return Fail<Value, Notice.InvalidUserInfError>(
                        error: Notice.InvalidUserInfError(
                            message: "userInfo is nil",
                            userInfo: notification.userInfo
                        )
                    ).eraseToAnyPublisher()
                }

                if let decode = name.decode, let value = try? decode(userInfo) {
                    return Just(value)
                        .setFailureType(to: Notice.InvalidUserInfError.self)
                        .eraseToAnyPublisher()
                } else if let value = notification.userInfo?[Const.infoKey] as? Value {
                    return Just(value)
                        .setFailureType(to: Notice.InvalidUserInfError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail<Value, Notice.InvalidUserInfError>(
                        error: Notice.InvalidUserInfError(
                            message: "info-key not found in userInfo",
                            userInfo: notification.userInfo
                        )
                    ).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func publisher(
        for name: Notice.Name<Void>,
        object: AnyObject? = nil
    ) -> AnyPublisher<Void, Never> {
        center
            .publisher(for: name.raw, object: object)
            .map { _ in }
            .eraseToAnyPublisher()
    }
#endif

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func notifications<Value>(
        named name: Notice.Name<Value>,
        object: AnyObject? = nil
    ) -> AsyncThrowingPublisher<AnyPublisher<Value, Notice.InvalidUserInfError>> {
        AsyncThrowingPublisher(publisher(for: name, object: object))
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func notifications(
        named name: Notice.Name<Void>,
        object: AnyObject? = nil
    ) -> AsyncPublisher<AnyPublisher<Void, Never>> {
        AsyncPublisher(publisher(for: name, object: object))
    }
}

// MARK: - Notice.Observer

@available(iOS, deprecated: 10)
@available(watchOS, deprecated: 3)
@available(tvOS, deprecated: 10)
@available(OSX, deprecated: 10.10)
extension Notice.Observer {
    public func invalidate() {
        center?.removeObserver(raw)
    }

    public func invalidated(by pool: Notice.ObserverPool) {
        pool.adding(self)
    }
}

// MARK: - NotificationCenter extension

extension Notice {
    public struct Extension {
        let base: Notice.Center
    }
}

extension NotificationCenter {
    public var nok: Notice.Extension {
        return Notice.Extension(base: Notice.Center(center: self))
    }
}

extension Notice.Extension {
    public func post<Value>(name: Notice.Name<Value>, with value: Value, from object: Any? = nil) {
        base.post(name: name, with: value, from: object)
    }

    public func post(name: Notice.Name<Void>, from object: Any? = nil) {
        base.post(name: name, from: object)
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public func observe<Value>(name: Notice.Name<Value>,
                               object: Any? = nil,
                               queue: OperationQueue? = nil,
                               using: @escaping (Value) -> Void) -> Notice.Observer {
        return base.observe(name: name,
                            object: object,
                            queue: queue, using: using)
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public func observe(
        name: Notice.Name<Void>,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        using: @escaping () -> Void
    ) -> Notice.Observer {
        base.observe(name: name, object: object, queue: queue, using: using)
    }


#if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func publisher<Value>(
        for name: Notice.Name<Value>,
        object: AnyObject? = nil
    ) -> AnyPublisher<Value, Notice.InvalidUserInfError> {
        base.publisher(for: name, object: object)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func publisher(
        for name: Notice.Name<Void>,
        object: AnyObject? = nil
    ) -> AnyPublisher<Void, Never> {
        base.publisher(for: name, object: object)
    }
#endif

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func notifications<Value>(
        named name: Notice.Name<Value>,
        object: AnyObject? = nil
    ) -> AsyncThrowingPublisher<AnyPublisher<Value, Notice.InvalidUserInfError>> {
        base.notifications(named: name, object: object)
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func notifications(
        named name: Notice.Name<Void>,
        object: AnyObject? = nil
    ) -> AsyncPublisher<AnyPublisher<Void, Never>> {
        base.notifications(named: name, object: object)
    }
}
