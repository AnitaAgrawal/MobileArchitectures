//
//  KeyboardHandlingManager.swift
//  MobileArchitectures
//
//  Created by Anita Agrawal on 03/03/18.
//  Copyright © 2018 Anita Agarwal. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardOnScrollView {
    weak var keyboardOnScrollView: UIScrollView!{get set}
}

class KeyboardHandlingManager {
    static var sharedInstance = KeyboardHandlingManager()
    var tapGest: UITapGestureRecognizer?
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @objc private func keyboardDidShow(notification : NSNotification) {
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
            updateScrollView(contentInset: contentInset)
        }
        dismissKeyboardGesture()
    }
    @objc private func keyboardWillHide(notification : NSNotification) {
        updateScrollView(contentInset: UIEdgeInsets.zero)
    }
    private func updateScrollView(contentInset: UIEdgeInsets) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard
            let vc = topViewControllerWithRootViewController(rootViewController: appDelegate?.window?.rootViewController) as? KeyboardOnScrollView
            else { return }
        vc.keyboardOnScrollView?.contentInset = contentInset
    }
    private func dismissKeyboardGesture() {
        if tapGest == nil {
            tapGest = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        }
        tapGest?.cancelsTouchesInView = false
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let vc = topViewControllerWithRootViewController(rootViewController: appDelegate?.window?.rootViewController)
        vc?.view.addGestureRecognizer(tapGest!)
    }
    @objc private func dismissKeyboard() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let vc = topViewControllerWithRootViewController(rootViewController: appDelegate?.window?.rootViewController)
        vc?.view.endEditing(true)
        if tapGest != nil {
            vc?.view.removeGestureRecognizer(tapGest!)
        }
    }
    
    func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: (UITabBarController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of:(UINavigationController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
}
