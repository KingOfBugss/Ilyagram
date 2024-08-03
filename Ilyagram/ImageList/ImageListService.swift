//
//  ImageListService.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 26.07.2024.
//

import Foundation

// MARK: - Structures
public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResualt: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let heigth: Int
    let likes: Int
    let description: String?
    var likeByUser: Bool
    let urls: UrlResults
}

struct UrlResults: Codable {
    let small: String
    let full: String
}

// MARK: - Class
class ImageListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    let requestBuilder = UrlRequestBuilder.share
    
    private let session = URLSession.shared
    private let imageOnPage = 10
    
    var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentPhotoTask: URLSessionTask?
}

extension ImageListService {
    func convertToViewModel(result photoResult: PhotoResualt) -> Photo {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return Photo(id: photoResult.id,
                     size: CGSize(width: Double(photoResult.width), height: Double(photoResult.heigth)),
                     createdAt: formatter.date(from: photoResult.createdAt ?? ""),
                     welcomeDescription: photoResult.description,
                     thumbImageURL: photoResult.urls.small,
                     largeImageURL: photoResult.urls.full,
                     isLiked: photoResult.likeByUser)
    }
    
    func makePhotosListRequest(page: Int) -> URLRequest? {
        requestBuilder.makeHttpRequest(
            path: "/photos"
            + "?page=\(page)"
            + "&&per_page=\(imageOnPage)"
        )
    }
    
    func mackeNextPageNumber() -> Int {
        guard let lastLoadedPage else { return 1 }
        let nextPage = lastLoadedPage + 1
        return nextPage
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if currentPhotoTask != nil { return }
        currentPhotoTask?.cancel()
        
        let nextPage = mackeNextPageNumber()
        
        guard let request = makePhotosListRequest(page: nextPage) else {
            print("ERROR: guard in ImageListService -> request")
            return
        }
        
        
        let task = session.load(for: request, decodableType: [PhotoResualt].self) { [weak self] (result: Result<[PhotoResualt], Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                self.currentPhotoTask = nil
                switch result {
                case .success(let photoResult):
                    var photos: [Photo] = []
                    photoResult.forEach { photo in
                        photos.append(self.convertToViewModel(result: photo))
                    }
                    self.photos += photos
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photos": self.photos]
                    )
                case .failure(let error):
                    print("ERROR: in task ImageListService \(error)")
                }
            }
        }
        
        self.currentPhotoTask = task
        task.resume()
    }
}

