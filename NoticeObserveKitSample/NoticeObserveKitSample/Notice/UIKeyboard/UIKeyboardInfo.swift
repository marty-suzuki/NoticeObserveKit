//
//  UIKeyboardInfo.swift
//  NoticeObserveKitSample
//
//  Created by 鈴木大貴 on 2016/12/27.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import NoticeObserveKit

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
