//
//  SplashViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 20.03.2024.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private var splashScrennLogo: UIImageView = {
        let imageSplashScreenLogo = UIImageView()
        imageSplashScreenLogo.image = UIImage(named: "Splash_screen_logo")
        imageSplashScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        
        return imageSplashScreenLogo
    }()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauthService = OAuth2Service()
    private var tokenInStorage: AuthTokenStorageProtocol = AccessKeyStorage.shared
    private var alertPresenter: AlertPresenterProtocol?
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkStatusOfAuth()
    }
    
    private func switchToAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        guard let viewController = viewController as? AuthViewController else { return }
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false)
        
        UIBlockingProgressHUD.window.rootViewController = navigationController
        UIBlockingProgressHUD.window.makeKeyAndVisible()
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            print("Invalid Configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController,didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            UIBlockingProgressHUD.show()
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func setupSplashViewController() {
        view.accessibilityIdentifier = "SplashViewController"
        view.backgroundColor = UIColor(named: "YP Background")
        view.addSubview(splashScrennLogo)
        
        NSLayoutConstraint.activate([
            splashScrennLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            splashScrennLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        ])
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauthService.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dissmiss()
            switch result {
            case .success:
                checkStatusOfAuth()
                self.switchToTabBarController()
            case .failure(let error):
                self.showLoginAlert(error: error)
                print("case .failure in fetchOAuthToken")
                break
            }
        }
    }
    
    func checkStatusOfAuth() {
        if  let token = tokenInStorage.token,
            token != "" {
            switchToTabBarController()
        } else {
            switchToAuthViewController()
            UIBlockingProgressHUD.dissmiss()
        }
    }
    
    func showLoginAlert(error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let alertModel = AlertModel(
                title: "Что-то пошло не так :(",
                message: "Не удалось войти в систему: \(error.localizedDescription)",
                buttonText: "Ok") {
                    self.checkStatusOfAuth()
                }
            self.alertPresenter?.showAlert(for: alertModel)
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
