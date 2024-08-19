//
//  AuthViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 12.03.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var webViewDelegate: WebViewViewControllerDelegate?
    
    var webViewPresenter = WebViewPresenter()
    
    var delegate: AuthViewControllerDelegate?
    
    var webViewViewController = WebViewViewController()
    
    private let showWebViewControllerSegueIdentifire = "SegueToAuth"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAuthImageView()
        configurAuthButton()
        configureBackButton()
    }
    
    @objc func didTapeAuthButton() {
        webViewViewController.delegate = self
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true)
//        let webView = WebViewViewController()
//        webView.delegate = self
//        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    private func configureAuthImageView() {
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
    }
    
    private func configurAuthButton() {
        let authButton = UIButton()
        authButton.setTitle("Войти", for: .normal)
        authButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        authButton.setTitleColor(UIColor(named: "YP Background"), for: .normal)
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
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "NavBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "NavBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Background")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewControllerSegueIdentifire {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {
                print("ERROR: Failed to prepare for *showWebViewControllerSegueIdentifire*")
                
                return
            }
            webViewPresenter.view = webViewViewController
            webViewViewController.presenter = webViewPresenter
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
