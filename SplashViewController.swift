//
//  SplashViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 20.03.2024.
//

import UIKit

class SplashViewController: UIViewController {
    private let oauthService = OAuth2Service()
    private var tokenInStorage: AuthTokenStorageProtocol = AccessKeyStorage()
 
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

    var window: UIWindow {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Не удается получить окно из UIApplication")
        }
        return window
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let logoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(named: "Splash_screen_logo")
            imageView.image = image
            return imageView
        }()
        view.backgroundColor = UIColor(named: "Background")
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = tokenInStorage.token {
            switchToTabBarController()
        } else {
            switchToAuthViewController()
        }
    }
    
    private func switchToAuthViewController() {
        guard let navigationController = mainStoryboard.instantiateViewController(
            withIdentifier: "NavigationController") as? UINavigationController,
              let authViewController = navigationController.viewControllers[0] as? AuthViewController else {
            preconditionFailure("Не удается получить NavigationController or AuthViewController из Storyboard")
        }
        authViewController.delegate = self
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauthService.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                tokenInStorage.storeAccessKey(newValue: code)
                self.switchToTabBarController()
            case .failure:
                print("case .failure in fetchOAuthToken")
                break
            }
        }
    }
}

extension SplashViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        fetchOAuthToken(code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print(#function)
    }
}
