//
//  AuthHelper.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 19.08.2024.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

class AuthHelper: AuthHelperProtocol {
    
    let authConfiguration: AuthConfiguration
    
    init(authConfiguration: AuthConfiguration = .standard) {
        self.authConfiguration = authConfiguration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authUrl() else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    func authUrl() -> URL? {
        guard var urlComponents = URLComponents(string: authConfiguration.authURLString) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
            URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: authConfiguration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }
}
