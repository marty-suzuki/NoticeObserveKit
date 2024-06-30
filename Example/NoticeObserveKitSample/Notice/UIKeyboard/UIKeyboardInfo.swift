//
//  UIKeyboardInfo.swift
//  NoticeObserveKitSample
//
//  Created by 鈴木大貴 on 2016/12/27.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import NoticeObserveKit

struct UIKeyboardInfo {
    let frame: CGRect
    let animationDuration: TimeInterval
    let animationCurve: UIView.AnimationOptions
    
    init(info: [AnyHashable : Any]) throws {
        guard
            let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            throw DecodeError()
        }
        self.frame = frame
        self.animationDuration = duration
        self.animationCurve = UIView.AnimationOptions(rawValue: curve)
    }

    struct DecodeError: Swift.Error {}
}

extension Notice.Names {
    static let keyboardWillShow = Notice.Name<UIKeyboardInfo>(
        UIResponder.keyboardWillShowNotification,
        decode: UIKeyboardInfo.init(info:)
    )
    static let keyboardWillHide = Notice.Name<UIKeyboardInfo>(
        UIResponder.keyboardWillHideNotification,
        decode: UIKeyboardInfo.init(info:)
    )
}
