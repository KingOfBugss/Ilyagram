//
//  LogOutService.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 13.08.2024.
//

import WebKit
import Foundation

class LogOutService {
    
    weak var view: ProfileViewControllerProtocol?
    
    static let shared = LogOutService()
    
    private init() { }
    
    func resetToken() {
        UIBlockingProgressHUD.dissmiss()
        guard AccessKeyStorage.shared.removeToken() else {
            assertionFailure("Cant remove token")
            return
        }
    }
    
    func resetView() {
        view?.loadProfile(nil)
    }
    
    func resetPhotos() {
        ImageListService.share.resetPhotos()
    }
    
    func cleanCookie() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in records.forEach { record in WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
        }
        }
    }
}
