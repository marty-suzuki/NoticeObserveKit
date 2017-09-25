//
//  NoticeObserveKit.swift
//  NoticeObserveKit
//
//  Created by marty-suzuki on 2016/12/27.
//
//

import UIKit

//MARK: - NoticeType
public protocol NoticeType {
    associatedtype InfoType
    static var name: Notification.Name { get }
    static var infoKey: String { get }
    static func observe(queue: OperationQueue?, object: Any?, recieving notiBlock: ((Notification) -> ())?, using infoBlock: @escaping (InfoType) -> ()) -> NoticeObserver
    static func post(from object: Any?, info: InfoType?)
    static func decode(_ userInfo: [AnyHashable : Any]) -> InfoType?
}

public extension NoticeType {
    static var infoKey: String {
        return "infoKey"
    }
    
    static func observe(queue: OperationQueue? = .main, object: Any? = nil, recieving notiBlock: ((Notification) -> ())? = nil, using infoBlock: @escaping (InfoType) -> ()) -> NoticeObserver {
        let observer = NotificationCenter.default.addObserver(forName: name, object: object, queue: queue) { notification in
            notiBlock?(notification)
            guard
                let userInfo = notification.userInfo,
                let info = decode(userInfo)
            else { return }
            infoBlock(info)
        }
        return NoticeObserver(observer: observer)
    }
    
    static func post(from object: Any? = nil, info: InfoType? = nil) {
        guard let info = info else {
            return
        }
        let userInfo: [AnyHashable : Any] = [infoKey : info]
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
    
    static func decode(_ userInfo: [AnyHashable : Any]) -> InfoType? {
        return userInfo[infoKey] as? InfoType
    }
}

public extension NoticeType where InfoType: NoticeUserInfoDecodable {
    static func post(from object: Any? = nil, info: InfoType? = nil) {
        guard let info = info else { return }
        let userInfo: [AnyHashable : Any] = [infoKey : info]
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
    
    static func decode(_ userInfo: [AnyHashable : Any]) -> InfoType? {
        guard let info = userInfo[infoKey] as? InfoType else {
            return InfoType(info: userInfo)
        }
        return info
    }
}

//MARK: - NoticeUserInfoDecodable
public protocol NoticeUserInfoDecodable {
    init?(info: [AnyHashable : Any])
}

//MARK: - NoticeObserver
public struct NoticeObserver {
    private let observer: NSObjectProtocol
    
    public init(observer: NSObjectProtocol) {
        self.observer = observer
    }
    
    @available(*, deprecated: 0.11.0)
    public func addObserverTo(_ pool: NoticeObserverPool) {
        pool.adding(observer)
    }
    
    public func disposed(by pool: NoticeObserverPool) {
        pool.adding(observer)
    }
    
    public func dispose() {
        NotificationCenter.default.removeObserver(observer)
    }
}

//MARK: - NoticeObserverPool
public class NoticeObserverPool {
    private var observers: [NSObjectProtocol] = []
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    
    public init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_lock(&mutex)
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
        observers.removeAll()
        pthread_mutex_unlock(&mutex)
        pthread_mutex_destroy(&mutex)
    }
    
    fileprivate func adding(_ observer: NSObjectProtocol) {
        pthread_mutex_lock(&mutex)
        observers = Array([observers, [observer]].joined())
        pthread_mutex_unlock(&mutex)
    }
}
