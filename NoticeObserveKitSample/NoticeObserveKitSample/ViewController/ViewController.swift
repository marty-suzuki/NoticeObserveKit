//
//  ViewController.swift
//  NoticeObserveKitSample
//
//  Created by 鈴木大貴 on 2016/12/27.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import NoticeObserveKit

class ViewController: UIViewController {

    private struct Const {
        static let textViewMinBottom: CGFloat = 12
    }
    
    private let searchBar = UISearchBar(frame: .zero)
    private lazy var cancelButton: UIBarButtonItem = {
        let selector = #selector(ViewController.didTapCancelButton(_:))
        return UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: selector)
    }()
    private var pool = NoticeObserverPool()
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = cancelButton
        
        textView.layoutManager.allowsNonContiguousLayout = false
        
        configureObservers()
    }
    
    private func configureObservers() {
        UIKeyboardWillShow.observe { [unowned self] in
            self.view.layoutIfNeeded()
            self.textViewBottomConstraint.constant = $0.frame.size.height + Const.textViewMinBottom
            UIView.animate(withDuration: $0.animationDuration, delay: 0, options: $0.animationCurve, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            self.setText("UIKeyboard will show = \($0)")
        }.disposed(by: pool)
        
        UIKeyboardWillHide.observe { [unowned self] in
            self.view.layoutIfNeeded()
            self.textViewBottomConstraint.constant = Const.textViewMinBottom
            UIView.animate(withDuration: $0.animationDuration, delay: 0, options: $0.animationCurve, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            self.setText("UIKeyboard will hide = \($0)")
        }.disposed(by: pool)
        
        NavigationControllerDidShow.observe { [unowned self] in
            self.setText("UINavigationController did show = \($0)")
        }.disposed(by: pool)
        
        NavigationControllerWillShow.observe { [unowned self] in
            if $0.viewController is NextViewController {
                $0.viewController.title = "Dummy VC"
            }
            self.setText("UINavigationController will show = \($0)")
        }.disposed(by: pool)
    }

    @objc private func didTapCancelButton(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func didTapDisposeButton(_ sender: UIButton) {
        pool = NoticeObserverPool()
    }
    
    private func setText(_ text: String) {
        let newText = (textView.text ?? "") + text + "\n\n"
        textView.text = newText
        textView.scrollRangeToVisible(NSRange(location: newText.characters.count, length: 0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
