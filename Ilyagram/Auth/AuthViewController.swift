//
//  AuthViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 12.03.2024.
//

import UIKit

class AuthViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButton()
        
        let segue1 = UIStoryboardSegue(identifier: "AuthSegue", source: AuthViewController(), destination: WebViewViewController())
        
        let authImage = UIImage(named: "Login Screen Image")
        let authImageView = UIImageView(image: authImage)
        
        authImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(authImageView)
        
        NSLayoutConstraint.activate([
            authImageView.heightAnchor.constraint(equalToConstant: 60),
            authImageView.widthAnchor.constraint(equalToConstant: 60),
            authImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            authImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        
        let authButton = UIButton()
        authButton.setTitle("Войти", for: .normal)
        authButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        authButton.setTitleColor(UIColor(named: "Background"), for: .normal)
        authButton.backgroundColor = UIColor.white
        authButton.addTarget(self, action: #selector(didTapeAuthButton), for: .touchUpInside)
        authButton.layer.cornerRadius = 16
        authButton.layer.masksToBounds = true
        authButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(authButton)
        
        NSLayoutConstraint.activate([
            authButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -124),
            authButton.widthAnchor.constraint(equalToConstant: 343),
            authButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc func didTapeAuthButton() {

    self.navigationController?.pushViewController(WebViewViewController(), animated: true)
    }
    
    func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "NavBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "NavBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "Background")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
