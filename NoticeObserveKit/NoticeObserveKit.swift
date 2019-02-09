//
//  NoticeObserveKit.swift
//  NoticeObserveKit
//
//  Created by marty-suzuki on 2016/12/27.
//
//

import Foundation

public typealias NoticeObserver = Notice.Observer
public typealias NoticeObserverPool = Notice.ObserverPool

//MARK: - NoticeType
@available(iOS, deprecated: 10)
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
