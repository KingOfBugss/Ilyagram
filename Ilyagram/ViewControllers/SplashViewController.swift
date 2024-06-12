//
//  SplashViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 20.03.2024.
//

import UIKit
import ProgressHUD

class SplashViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauthService = OAuth2Service()
    private var tokenInStorage: AuthTokenStorageProtocol = AccessKeyStorage.shared
    private var alertPresenter: AlertPresenterProtocol?
 
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let logoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(named: "Splash_screen_logo")
            imageView.image = image
            return imageView
        }()
        view.backgroundColor = UIColor(named: "YP Background")
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
//        checkStatusOfAuth()
//        resetToken()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkStatusOfAuth()
    }
    
    private func switchToAuthViewController() {
        guard let navigationController = mainStoryboard.instantiateViewController(
            withIdentifier: "NavigationController") as? UINavigationController,
              let authViewController = navigationController.viewControllers[0] as? AuthViewController else {
            preconditionFailure("Не удается получить NavigationController or AuthViewController из Storyboard")
        }
        authViewController.delegate = self
        UIBlockingProgressHUD.window.rootViewController = navigationController
        UIBlockingProgressHUD.window.makeKeyAndVisible()
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
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
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile { [weak self] profileResult in
            switch profileResult {
            case .success(let profile):
                let username = profile.username
                self?.fetchProfileImage(profileUsername: username)
            case .failure(let error):
                self?.showLoginAlert(error: error)
                UIBlockingProgressHUD.dissmiss()
            }
        }
    }
    
    private func fetchProfileImage(profileUsername: String) {
        profileImageService.fetchProfileImageURL(username: profileUsername) { [weak self] profileImageUrl in
            guard let self else { return }
            switch profileImageUrl {
            case .success:
                switchToTabBarController()
            case .failure(let error):
                self.showLoginAlert(error: error)
                print("case .failure in fetchProfileImage")
                break
            }
        }
    }
    
    func resetToken() {
        UIBlockingProgressHUD.dissmiss()
        guard AccessKeyStorage.shared.removeToken() else {
            assertionFailure("Cant remove token")
            return
        }
    }
    
    func checkStatusOfAuth() {
        UIBlockingProgressHUD.show()
        if  let token = tokenInStorage.token,
            token != "" {
            fetchProfile(token: token)
            switchToTabBarController()
            UIBlockingProgressHUD.dissmiss()
            
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
