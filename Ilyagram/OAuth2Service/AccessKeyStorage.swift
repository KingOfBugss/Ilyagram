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
            guard let token = usDefault.string(forKey: Token.accessToken.rawValue) else {
                print("ERROR: with get usDefault value('Key')")
                return .init()
            }
            return token
        }
    }
    
    func storeAccessKey(newValue: String) {
        usDefault.setValue(newValue, forKey: Token.accessToken.rawValue)
    }
}
