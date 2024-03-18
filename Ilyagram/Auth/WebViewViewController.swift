//
//  WebViewViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 14.03.2024.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    private let uiWkWeb = WKWebView()
    private let progresView = UIProgressView()
    
    weak var delegate: WebViewViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiWkWeb.navigationDelegate = self
        
        loadAuthView()
        
        uiWkWeb.backgroundColor = .white
        uiWkWeb.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uiWkWeb)
        
        NSLayoutConstraint.activate([
            uiWkWeb.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            uiWkWeb.leftAnchor.constraint(equalTo: view.leftAnchor),
            uiWkWeb.rightAnchor.constraint(equalTo: view.rightAnchor),
            uiWkWeb.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        progresView.tintColor = UIColor(named: "Background")
        progresView.setProgress(0.5, animated: true)
        progresView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progresView)
        
        NSLayoutConstraint.activate([
            progresView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progresView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            progresView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0)])
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка инициализации URLComponents")
            
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        guard let url = urlComponents.url else {
            print("Ошибка формирования URL")
            
            return
        }
        
        let request = URLRequest(url: url)
        uiWkWeb.load(request)
    }
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
