//
//  Notice.swift
//  NoticeObserveKit
//
//  Created by marty-suzuki on 2019/01/25.
//

import Foundation

// MARK: - Notice definition

public enum Notice {

    public final class Center {

        public static let `default` = Center(center: .default)

        let center: NotificationCenter

        init(center: NotificationCenter) {
            self.center = center
        }
    }

    public class Names {
        fileprivate init() {}
    }

    public final class Name<Value>: Names {

        let raw: Notification.Name

        public convenience init(name: String) {
            self.init(Notification.Name(name))
        }

        public init(_ name: Notification.Name) {
            self.raw = name
            super.init()
        }
    }

    public final class Observer {

        private(set) weak var center: NotificationCenter?
        let raw: NSObjectProtocol

        init(center: NotificationCenter, raw: NSObjectProtocol) {
            self.center = center
            self.raw = raw
        }
    }

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
}

// MARK: - Notice.Center (Codable)

extension Notice.Center {
    public func post<Value: Codable>(name: Notice.Name<Value>, with value: Value, from object: Any? = nil) {
        do {
            let data = try JSONEncoder().encode(value)
            let userInfo = (try JSONSerialization.jsonObject(with: data, options: [])) as? [AnyHashable: Any]
            center.post(name: name.raw, object: object, userInfo: userInfo)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    public func observe<Value: Codable>(name: Notice.Name<Value>,
                                        object: Any? = nil,
                                        queue: OperationQueue? = nil,
                                        using: @escaping (Value) -> Void) -> Notice.Observer {
        let observer = center.addObserver(forName: name.raw, object: object, queue: queue) { notification in
            guard let userInfo = notification.userInfo else {
                return
            }

            do {
                let data = try JSONSerialization.data(withJSONObject: userInfo, options: [])
                let value = try JSONDecoder().decode(Value.self, from: data)
                using(value)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        return Notice.Observer(center: center, raw: observer)
    }
}

// MARK: - Notice.Center (NoticeUserInfoDecodable)

extension Notice.Center {
    @available(iOS, unavailable)
    public func post<Value: NoticeUserInfoDecodable>(name: Notice.Name<Value>, with value: Value, from object: Any? = nil) {}

    public func observe<Value: NoticeUserInfoDecodable>(name: Notice.Name<Value>,
                                                        object: Any? = nil,
                                                        queue: OperationQueue? = nil,
                                                        using: @escaping (Value) -> Void) -> Notice.Observer {
        let observer = center.addObserver(forName: name.raw, object: object, queue: queue) { notification in
            guard
                let userInfo = notification.userInfo,
                let value = Value(info: userInfo)
                else {
                    return
            }
            using(value)
        }
        return Notice.Observer(center: center, raw: observer)
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

    public func observe<Value>(name: Notice.Name<Value>,
                               object: Any? = nil,
                               queue: OperationQueue? = nil,
                               using: @escaping (Value) -> Void) -> Notice.Observer {
        let observer = center.addObserver(forName: name.raw, object: object, queue: queue) { notification in
            guard let value = notification.userInfo?[Const.infoKey] as? Value else {
                return
            }
            using(value)
        }
        return Notice.Observer(center: center, raw: observer)
    }
}

// MARK: - Notice.Observer

extension Notice.Observer {
    public func invalidate() {
        center?.removeObserver(raw)
    }

    public func invalidated(by pool: Notice.ObserverPool) {
        pool.adding(self)
    }
}
