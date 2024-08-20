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

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController {
    
    var presenter: WebViewPresenterProtocol?
    
    weak var delegate: WebViewViewControllerDelegate?
    
    private var estimateProgressObservation: NSKeyValueObservation?
    private var uiWkWeb = WKWebView()
    private var progresView = UIProgressView()
    private var backwardButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createWebView()
        creatBackwardButton()
        createProgressView()
        presenter?.viewDidLoad()
        addWebViewLoadingObserver()
        uiWkWeb.navigationDelegate = self
    }
    
    @objc private func didTapeBackwardButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func creatBackwardButton() {
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        backwardButton.setImage(UIImage(named: "Backword_button"), for: .normal)
        backwardButton.tintColor = UIColor(named: "YP Background")
        backwardButton.addTarget(self, action: #selector(didTapeBackwardButton), for: .touchUpInside)
        
        view.addSubview(backwardButton)
        
        NSLayoutConstraint.activate([
            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backwardButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 9)
        ])
    }
    
    private func createWebView() {
        uiWkWeb.backgroundColor = .white
        uiWkWeb.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(uiWkWeb)
        
        NSLayoutConstraint.activate([
            uiWkWeb.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            uiWkWeb.leftAnchor.constraint(equalTo: view.leftAnchor),
            uiWkWeb.rightAnchor.constraint(equalTo: view.rightAnchor),
            uiWkWeb.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    private func createProgressView() {
        progresView.tintColor = UIColor(named: "YP Background")
        progresView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progresView)
        
        NSLayoutConstraint.activate([
            progresView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progresView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            progresView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
        ])
    }
    
    private func addWebViewLoadingObserver() {
        estimateProgressObservation = uiWkWeb.observe(\.estimatedProgress,
                                                       options: [],
                                                       changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            presenter?.didUpdateProgressValue(uiWkWeb.estimatedProgress)
        })
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
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}

extension WebViewViewController: WebViewViewControllerProtocol {
    func load(request: URLRequest) {
        uiWkWeb.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progresView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progresView.isHidden = isHidden
    }
}
