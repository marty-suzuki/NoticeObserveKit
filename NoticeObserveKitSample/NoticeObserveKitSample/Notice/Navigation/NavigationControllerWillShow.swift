//
//  NavigationControllerWillShow.swift
//  NoticeObserveKitSample
//
//  Created by 鈴木大貴 on 2016/12/28.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import NoticeObserveKit

struct NavigationControllerWillShow: NoticeType {
    typealias InfoType = NavigationControllerContent
    static var name = Notification.Name("navigationControllerWillShow")
}
