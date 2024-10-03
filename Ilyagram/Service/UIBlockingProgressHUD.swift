//
//  UIBlockingProgressHUD.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 21.05.2024.
//

import UIKit
import ProgressHUD

class UIBlockingProgressHUD {
    static var window: UIWindow {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Не удается получить окно из UIApplication")
        }
        return window
    }
    
    static func show() {
        window.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dissmiss() {
        window.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
