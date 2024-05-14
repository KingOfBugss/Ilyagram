//
//  OAuth2Service.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 18.03.2024.
//

import UIKit

protocol OAuth2ServiceProtocol: AnyObject {
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void)
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

class OAuth2Service {
    
    private let storage = AccessKeyStorage()
    private var currentUrlTask: URLSessionTask?
    private var lastCode: String?
    
    
    let session = URLSession.shared
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var window: UIWindow {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration: unable to get window from UIApplication")
        }
        return window
    }
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    func makeURLRequest(baseURL url: URL,
                        pathComponent component: String?,
                        queryItems items: [URLQueryItem]?,
                        requestHttpMethod method: String,
                        addValue value: String?,
                        forHTTPHeaderField headerField: String?) -> URLRequest {
        var fullURL: URL
        if let component = component {
            fullURL = url.appendingPathComponent(component)
        } else {
            fullURL = url
        }
        lazy var urlComponents = URLComponents()
        if let items = items,
           let valueComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) {
            urlComponents = valueComponents
            urlComponents.queryItems = items
            fullURL = urlComponents.url ?? fullURL
        }
        var request = URLRequest(url: fullURL)
        request.httpMethod = method
        if let value = value,
           let headerField = headerField {
            request.addValue(value, forHTTPHeaderField: headerField)
        }
        return request
    }
    
    private func makeOAuthTokenRequest(with code: String) -> URLRequest {
        let baseUrl = Constants.defaultBaseURL
        let url = URL(string: "/oauth/token"
                      + "?client_id=\(Constants.accessKey)"
                      + "&&client_secret=\(Constants.secretKey)"
                      + "&&redirect_uri=\(Constants.redirectURI)"
                      + "&&code=\(code)"
                      + "&&grant_type=authorization_code",
                      relativeTo: baseUrl
        )!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard lastCode != code else { return }
        currentUrlTask?.cancel()
        lastCode = code
        
        let request = makeURLRequest(baseURL: Constants.unsplashTokenURL,
                                     pathComponent: nil,
                                     queryItems: [
                                        URLQueryItem(name: "client_id", value: Constants.accessKey),
                                        URLQueryItem(name: "client_secret", value: Constants.secretKey),
                                        URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
                                        URLQueryItem(name: "code", value: code),
                                        URLQueryItem(name: "grant_type", value: "authorization_code")
                                     ],
                                     requestHttpMethod: "POST",
                                     addValue: nil,
                                     forHTTPHeaderField: nil)
        
        let task = session.data(for: request) { 
            [weak self] result in
            guard let self else { preconditionFailure("Cannot make weak link") }
            switch result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let json = try? jsonDecoder.decode(OAuthTokenResponseBody.self, from: data)
                let accessToken = json?.accessToken
                completion(.success(accessToken ?? ""))
                self.currentUrlTask = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastCode = nil
            }
        }
        self.currentUrlTask = task
        task.resume()
    }
}
