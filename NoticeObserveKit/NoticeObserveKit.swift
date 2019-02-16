//
//  NoticeObserveKit.swift
//  NoticeObserveKit
//
//  Created by marty-suzuki on 2016/12/27.
//
//

import Foundation

@available(iOS, deprecated: 10, renamed: "Notice.Observer")
@available(watchOS, deprecated: 3, renamed: "Notice.Observer")
@available(tvOS, deprecated: 10, renamed: "Notice.Observer")
@available(OSX, deprecated: 10.10, renamed: "Notice.Observer")
public typealias NoticeObserver = Notice.Observer

@available(iOS, deprecated: 10, renamed: "Notice.ObserverPool")
@available(watchOS, deprecated: 3, renamed: "Notice.ObserverPool")
@available(tvOS, deprecated: 10, renamed: "Notice.ObserverPool")
@available(OSX, deprecated: 10.10, renamed: "Notice.ObserverPool")
public typealias NoticeObserverPool = Notice.ObserverPool

//MARK: - NoticeType
@available(iOS, deprecated: 10)
@available(watchOS, deprecated: 3)
@available(tvOS, deprecated: 10)
@available(OSX, deprecated: 10.10)
public protocol NoticeType {
    associatedtype InfoType
    static var name: Notification.Name { get }
    static var infoKey: String { get }
    static func observe(queue: OperationQueue?, object: Any?, recieving notiBlock: ((Notification) -> ())?, using infoBlock: @escaping (InfoType) -> ()) -> NoticeObserver
    static func post(from object: Any?, info: InfoType?)
    static func decode(_ userInfo: [AnyHashable : Any]) -> InfoType?
}

extension NoticeType {

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public static var infoKey: String {
        return "infoKey"
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public static func observe(queue: OperationQueue? = .main, object: Any? = nil, recieving notiBlock: ((Notification) -> ())? = nil, using infoBlock: @escaping (InfoType) -> ()) -> NoticeObserver {
        let center = NotificationCenter.default
        let observer = center.addObserver(forName: name, object: object, queue: queue) { notification in
            notiBlock?(notification)
            guard
                let userInfo = notification.userInfo,
                let info = decode(userInfo)
            else { return }
            infoBlock(info)
        }
        return NoticeObserver(center: center, raw: observer)
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public static func post(from object: Any? = nil, info: InfoType? = nil) {
        guard let info = info else {
            return
        }
        let userInfo: [AnyHashable : Any] = [infoKey : info]
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public static func decode(_ userInfo: [AnyHashable : Any]) -> InfoType? {
        return userInfo[infoKey] as? InfoType
    }
}

extension NoticeType where InfoType: NoticeUserInfoDecodable {

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public static func post(from object: Any? = nil, info: InfoType? = nil) {
        guard let info = info else { return }
        let userInfo: [AnyHashable : Any] = [infoKey : info]
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }

    @available(iOS, deprecated: 10)
    @available(watchOS, deprecated: 3)
    @available(tvOS, deprecated: 10)
    @available(OSX, deprecated: 10.10)
    public static func decode(_ userInfo: [AnyHashable : Any]) -> InfoType? {
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

extension NoticeObserver {

    @available(iOS, deprecated: 10, renamed: "invalidated(by:)")
    @available(watchOS, deprecated: 3, renamed: "invalidated(by:)")
    @available(tvOS, deprecated: 10, renamed: "invalidated(by:)")
    @available(OSX, deprecated: 10.10, renamed: "invalidated(by:)")
    public func disposed(by pool: NoticeObserverPool) {
        invalidated(by: pool)
    }
}
