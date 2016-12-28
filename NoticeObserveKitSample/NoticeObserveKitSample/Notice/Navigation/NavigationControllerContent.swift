//
//  NavigationControllerContent.swift
//  NoticeObserveKitSample
//
//  Created by 鈴木大貴 on 2016/12/28.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import NoticeObserveKit

struct NavigationControllerContent {
    let viewController: UIViewController
    let animated: Bool
}

extension NavigationControllerContent: NoticeUserInfoDecodable {
    init?(info: [AnyHashable : Any]) {
        guard
            let viewController = info["viewController"] as? UIViewController,
            let animated = info["animated"] as? Bool
            else {
                return nil
        }
        self.viewController = viewController
        self.animated = animated
    }
    
    func dictionaryRepresentation() -> [AnyHashable : Any] {
        return [
            "viewController" : viewController,
            "animated" : animated
        ]
    }
}
