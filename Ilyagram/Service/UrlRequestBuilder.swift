//
//  RequestBuilder.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 21.05.2024.
//

import Foundation

class UrlRequestBuilder {
    
    static let share = UrlRequestBuilder()
    let tokenStorage = AccessKeyStorage()
    
    func makeHttpRequest(path: String, httpMethod: String? = nil, baseURLString: String? = nil) -> URLRequest? {
        guard
            let url = URL(string: baseURLString ?? "https://api.unsplash.com"),
            let baseUrl = URL(string: path, relativeTo: url)
        else {
            print("guard UrlRequestBuilder -> url")
            return nil
        }
        
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        
        if let token = tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
