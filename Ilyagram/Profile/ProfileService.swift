//
//  ProfileService.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 21.05.2024.
//

import Foundation

protocol ProfileLoading: AnyObject {
    var profile: Profile? { get }
    func fetchProfile(_ completion: @escaping(Result<Profile, Error>)-> Void)
}

struct UserResult: Decodable {
    let profileImage: ProfileImage
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession: URLSession
    private let requestBuilder: UrlRequestBuilder
    private var currentTask: URLSessionTask?
    private (set) var profile: Profile?
    
    init(urlSession: URLSession = .shared, requestBuilder: UrlRequestBuilder = .share) {
        self.urlSession = urlSession
        self.requestBuilder = requestBuilder
    }
    
    func mackeProfileRequest() -> URLRequest? {
        requestBuilder.makeHttpRequest(path: "/me")
    }
}

extension Profile {
    init(profile: ProfileResult) {
        self.init(username: profile.username,
                  name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
                  loginName: "\(profile.username)",
                  bio: profile.bio)
    }
}

extension ProfileService: ProfileLoading {
    func fetchProfile(_ completion: @escaping (Result<Profile, any Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if currentTask != nil { return }
        currentTask?.cancel()
        
        guard let request = mackeProfileRequest() else {
            assertionFailure("Ошибка в запросе ProfileService")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let session = URLSession.shared
        let task = session.load(for: request, decodableType: ProfileResult.self) { [weak self] result in
            guard let self else { return }
            
            self.currentTask = nil
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(profile: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.currentTask = task
        task.resume()
    }
}
