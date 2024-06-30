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

    private var tasks: [Task<Void, Error>] = []

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
        let nok = NotificationCenter.default.nok

        tasks.append(Task { [unowned self] in
            for try await keybordInfo in nok.notifications(named: .keyboardWillShow) {
                self.view.layoutIfNeeded()
                self.textViewBottomConstraint.constant = keybordInfo.frame.size.height + Const.textViewMinBottom
                UIView.animate(withDuration: keybordInfo.animationDuration, delay: 0, options: keybordInfo.animationCurve, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                self.setText("UIKeyboard will show = \(keybordInfo)")
            }
        })

        tasks.append(Task { [unowned self] in
            for try await keybordInfo in nok.notifications(named: .keyboardWillHide) {
                self.view.layoutIfNeeded()
                self.textViewBottomConstraint.constant = Const.textViewMinBottom
                UIView.animate(withDuration: keybordInfo.animationDuration, delay: 0, options: keybordInfo.animationCurve, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
                self.setText("UIKeyboard will hide = \(keybordInfo)")
            }
        })

        tasks.append(Task { [unowned self] in
            for try await value in nok.notifications(named: .navigationControllerDidShow) {
                self.setText("UINavigationController did show = \(value)")
            }
        })

        tasks.append(Task { [unowned self] in
            for try await value in nok.notifications(named: .navigationControllerWillShow) {
                if value.viewController is NextViewController {
                    value.viewController.title = "Dummy VC"
                }
                self.setText("UINavigationController will show = \(value)")
            }
        })
    }

    @objc private func didTapCancelButton(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func didTapDisposeButton(_ sender: UIButton) {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    private func setText(_ text: String) {
        let newText = (textView.text ?? "") + text + "\n\n"
        textView.text = newText
        textView.scrollRangeToVisible(NSRange(location: newText.count, length: 0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
