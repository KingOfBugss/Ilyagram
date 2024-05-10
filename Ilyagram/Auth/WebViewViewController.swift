//
//  WebViewViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 14.03.2024.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewViewController: UIViewController {
    
    private lazy var backwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "YP Black"), for: .normal)
        button.addTarget(self, action: #selector(didTapeBackwardButton), for: .touchUpInside)
        return button
    }()
    
    private var uiWkWeb: WKWebView = {
        let view = WKWebView()
        
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private let progresView = UIProgressView()
    private let cache = URLCache()
    
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAuthView()
        
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {})
        
        uiWkWeb.navigationDelegate = self
        view.addSubview(uiWkWeb)
        
        NSLayoutConstraint.activate([
            uiWkWeb.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            uiWkWeb.leftAnchor.constraint(equalTo: view.leftAnchor),
            uiWkWeb.rightAnchor.constraint(equalTo: view.rightAnchor),
            uiWkWeb.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        progresView.tintColor = UIColor(named: "Background")
        progresView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progresView)
        
        NSLayoutConstraint.activate([
            progresView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progresView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            progresView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0)])
        
        updateProgress()
    }
    
    @objc private func didTapeBackwardButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        uiWkWeb.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        updateProgress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        uiWkWeb.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateProgress() {
        progresView.progress = Float(uiWkWeb.estimatedProgress)
        progresView.isHidden = fabs(uiWkWeb.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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

private extension WebViewViewController {
    func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка инициализации URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            print("Ошибка формирования URL")
            
            return
        }
        
        let request = URLRequest(url: url)
        uiWkWeb.load(request)
    }
}

//https://unsplash.com/oauth/authorize/native?code=QvRdJrpNfuFOP9Q0m_wF7R-prLkXRCv3GvfbLRujs8o
