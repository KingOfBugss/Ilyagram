//
//  AlertPresenter.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 07.06.2024.
//

import UIKit
import Foundation

protocol AlertPresenterProtocol: AnyObject {
    func showAlert(for result: AlertModel)
}

final class AlertPresenter {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

extension AlertPresenter: AlertPresenterProtocol {
    
    func showAlert(for result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "AlertAuthError"
        
        let alertAction = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion?()
        }
        alert.addAction(alertAction)
        
        if let secondButtonText = result.secondButtonText {
            let secondAction = UIAlertAction(title: secondButtonText, style: .default) { _ in
                result.secondCompletion?()
            }
            alert.addAction(secondAction)
        }
        
        if var topController = UIApplication.shared.windows[0].rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true)
        }
    }
}
