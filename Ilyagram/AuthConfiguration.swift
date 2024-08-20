//
//  Constants.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 11.03.2024.
//

import Foundation

enum Constants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let accessKey = "NMC5oIL6HlR1i5WmEATn4E96CA97QuOdjPhkI_Hg90A"
    static let secretKey = "65r6Y-h9U-rL-4ZYR4NRxLM7soURAMcIp9_E1znzpQo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    static let dateIsoFormatter = ISO8601DateFormatter()
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM YYYY"
        return dateFormatter
    }()
    static var unsplashTokenURL: URL {
        guard let url = URL(string: unsplashTokenURLString) else {
            preconditionFailure("AuthConfiguration -> Constant: не получилось собрать unsplashTokenURL")
        }
        return url
    }
    static var defaultBaseURL: URL {
        guard  let url = URL(string: "https://unsplash.com") else {
            preconditionFailure("AuthConfiguration -> Constant: не получилось собрать defaultBaseURL")
        }
        return url
    }
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        AuthConfiguration(accessKey: Constants.accessKey,
                          secretKey: Constants.secretKey,
                          redirectURI: Constants.redirectURI,
                          accessScope: Constants.accessScope,
                          defaultBaseURL: Constants.defaultBaseURL,
                          authURLString: Constants.unsplashAuthorizeURLString)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}

