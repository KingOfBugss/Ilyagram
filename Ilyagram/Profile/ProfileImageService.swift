//
//  ProfileImageService.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 30.05.2024.
//

import Foundation

protocol ProfileImageServiceProtocol {
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    
    private let session = URLSession.shared
    private let requestBuilder = UrlRequestBuilder.share
    
    private var currentTask: URLSessionTask?
    private var lastUsername: String?
    private lazy var tokenStorage: AuthTokenStorageProtocol = AccessKeyStorage.shared
    private lazy var profileService: ProfileLoading = ProfileService.shared
    private(set) var avatarURL: URL?
    
    private init() { }
    
    private func makeRequest(username: String) -> URLRequest? {
        requestBuilder.makeHttpRequest(path: "/users/\(username)")
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        if currentTask != nil { return }
        currentTask?.cancel()
        
        guard let request = makeRequest(username: username) else {
            assertionFailure("Ошибка запроса ProfileImageService")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = session.load(for: request, decodableType: UserResult.self) { [weak self] result in
            guard let self else { return }
            
            self.currentTask = nil
            
            switch result {
            case .success(let profiResponse):
                let profilePhoto = profiResponse.profileImage.medium
                self.avatarURL = URL(string: profilePhoto)
                completion(.success(profilePhoto))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.currentTask = task
        task.resume()
    }
}
