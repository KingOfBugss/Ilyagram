//
//  AccessKeyStorage.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 19.03.2024.
//

import Foundation
import SwiftKeychainWrapper

protocol AuthTokenStorageProtocol {
    var token: String? { get }
}

class AccessKeyStorage: AuthTokenStorageProtocol {
    
    static let shared = AccessKeyStorage()
    private let keyChainWrapper = KeychainWrapper.standard
    
    private enum Token {
        static let accessToken = "AccessToken"
    }
    
    private let userDefault = UserDefaults.standard
    
    var token: String? {
        get {
            keyChainWrapper.string(forKey: Token.accessToken)
        }
        
        set {
            guard let newValue else { return }
            keyChainWrapper.set(newValue, forKey: Token.accessToken)
        }
    }
    
    func removeToken() -> Bool {
        keyChainWrapper.removeObject(forKey: Token.accessToken)
    }
}
