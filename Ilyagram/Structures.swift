//
//  Structures.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 15.08.2024.
//

import Foundation

// MARK: Structures for ImageListService

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    let thumbSize: CGSize
}

public struct PhotoResualt: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likes: Int
    let description: String?
    var likeByUser: Bool?
    let urls: UrlResults
}

public struct UrlResults: Codable {
    let small: String
    let full: String
}

public struct LikeResult: Codable {
    let photo: PhotoLikeResult
}

public struct PhotoLikeResult: Codable {
    let likedByUser: Bool
}

// MARK: Structures for OAuth2Service

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

// MARK: Structure for ProfileService

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

// MARK: Profile init
extension Profile {
    init(profile: ProfileResult) {
        self.init(username: profile.username,
                  name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
                  loginName: "\(profile.username)",
                  bio: profile.bio)
    }
}

