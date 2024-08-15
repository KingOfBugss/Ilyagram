//
//  ImageListService.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 26.07.2024.
//

import Foundation
// MARK: - Class
final class ImageListService {
    
    static let share = ImageListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let requestBuilder = UrlRequestBuilder.share
    private let session = URLSession.shared
    private let imageOnPage = 10
    
    private var lastLoadedPage: Int?
    private var currentPhotoTask: URLSessionTask?
    private var currentLikeTask: URLSessionTask?
    
    var photos: [Photo] = []
}

extension ImageListService {
    func convertToViewModel(result photoResult: PhotoResualt) -> Photo {
        
        let thumbWidth = 200.0
        let aspectRatio = Double(photoResult.width) / Double(photoResult.height)
        let thumbHeight = thumbWidth / aspectRatio
        
        return Photo(id: photoResult.id,
                     size: CGSize(width: Double(photoResult.width), height: Double(photoResult.height)),
                     createdAt: Constants.dateIsoFormatter.date(from: photoResult.createdAt ?? ""),
                     welcomeDescription: photoResult.description,
                     thumbImageURL: photoResult.urls.small,
                     largeImageURL: photoResult.urls.full,
                     isLiked: photoResult.likeByUser ?? false,
                     thumbSize: CGSize(width: thumbWidth, height: thumbHeight)
        )
    }
    
    func resetPhotos() {
        lastLoadedPage = nil
        photos = []
    }
    
    func makeLikeRequest(for id: String, with method: String) -> URLRequest? {
        requestBuilder.makeHttpRequest(path: "/photos/\(id)/like",
                                       httpMethod: method)
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
                    photoResult.forEach { photo in
                        self.photos.append(self.convertToViewModel(result: photo))
                    }
                    self.photos += self.photos
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photos": self.photos]
                    )
                case .failure(let error):
                    print("ERROR: in photoTask ImageListService \(error)")
                }
            }
        }
        
        self.currentPhotoTask = task
        task.resume()
    }
    
    func changeLike(
        photoId: String,
        indexPath: IndexPath,
        isLike: Bool,
        _ completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if currentLikeTask != nil { return }
        currentLikeTask?.cancel()
        
        let method = isLike ? "POST" : "DELETE"
        
        guard let request = makeLikeRequest(for: photoId, with: method) else {
            assertionFailure("Invalid request")
            print(NetworkError.invalidRequest)
            return
        }
        
        let task = session.load(for: request, decodableType: LikeResult.self) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                self.currentLikeTask = nil
                switch result {
                case .success(let photoLiked):
                    let liked = photoLiked.photo.likedByUser
                    self.photos[indexPath.row].isLiked = liked
                    completion(.success(liked))
                case .failure(let error):
                    print("ERROR: in LikeTask ImageListService \(error)")
                }
            }
        }
        self.currentLikeTask = task
        task.resume()
    }
}

