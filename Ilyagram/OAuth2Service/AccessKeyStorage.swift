//
//  AccessKeyStorage.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 19.03.2024.
//

import Foundation

protocol AuthTokenStorageProtocol {
    var token: String? { get }
    func storeAccessKey(newValue: String)
}

class AccessKeyStorage: AuthTokenStorageProtocol {
    
    private enum Token: String {
        case accessToken
    }
    
    private let usDefault = UserDefaults.standard
    
    var token: String? {
        get {
            return usDefault.string(forKey: Token.accessToken.rawValue)
        }
    }
    
    func storeAccessKey(newValue: String) {
        usDefault.setValue(newValue, forKey: Token.accessToken.rawValue)
    }
}
