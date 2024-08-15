//
//  Constants.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 11.03.2024.
//

import Foundation

enum Constants {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM YYYY"
        return dateFormatter
    }()
    static let accessKey = "NMC5oIL6HlR1i5WmEATn4E96CA97QuOdjPhkI_Hg90A"
    static let secretKey = "65r6Y-h9U-rL-4ZYR4NRxLM7soURAMcIp9_E1znzpQo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://unsplash.com")
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    static var unsplashTokenURL: URL {
        guard let url = URL(string: unsplashTokenURLString) else {
            preconditionFailure("Unable to construct unsplashTokenURL")
        }
        return url
    }
}
