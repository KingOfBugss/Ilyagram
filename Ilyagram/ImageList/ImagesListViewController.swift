//
//  ViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 13.02.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let imageListService = ImageListService.share
    private let showSingleImageSegueIdentifire = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private let cell = ImagesListCell()
    
    var photos: [Photo] = []
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageListService.fetchPhotosNextPage()
        setupNotificationObserver()
        updateTableViewAnimated()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifire {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath
            else {
                super.prepare(for: segue, sender: sender)
                return
            }
            guard let photo = returnPhotoModelAt(indexPath: indexPath) else {
                print("ERROR: ImagesListViewController -> prepare")
                return
            }
            viewController.largeImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func needLoadNextPhotos (indexPath: IndexPath) {
        if indexPath.row + 2 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func setupNotificationObserver() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
        self.updateTableViewAnimated()
    }
    
    func returnPhotoModelAt (indexPath: IndexPath) -> Photo? {
        photos[indexPath.row]
    }
    
    func updateTableViewAnimated() {
        let oldCountPhotos = photos.count
        photos = imageListService.photos
        let newCountPhotos = imageListService.photos.count
        
        if oldCountPhotos != newCountPhotos {
            tableView.performBatchUpdates {
                var indexPath : [IndexPath] = []
                for i in oldCountPhotos..<newCountPhotos {
                    indexPath.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPath, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func cellHeightRowAt(indexPath: IndexPath) -> CGFloat {
        let imageInsets = (top: CGFloat(4), left: CGFloat(16), bottom: CGFloat(4), right: CGFloat(16))
        let thumbImageSize = photos[indexPath.row].thumbSize
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = thumbImageSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = thumbImageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func likeDidTapByUser(_ cell: ImagesListCell, indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, indexPath: indexPath, isLike: !photo.isLiked) { [weak self ] result in
            guard let self else { return }
            switch result {
            case .success(let isLiked):
                self.photos[indexPath.row].isLiked = isLiked
                cell.setLiked(isLiked)
                UIBlockingProgressHUD.dissmiss()
            case .failure(let error):
                UIBlockingProgressHUD.dissmiss()
                print("ERROR: in likeDidTapByUser \(error)")
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifire, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.cellHeightRowAt(indexPath: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        guard let photos = returnPhotoModelAt(indexPath: indexPath) else {
            preconditionFailure("ERROR: не могу достать фото из массива")
        }
        
        if cell.loadCell(from: photos) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let visibleRows = tableView.indexPathsForVisibleRows, indexPath == visibleRows.last {
            needLoadNextPhotos(indexPath: indexPath)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func likeDidTapByUser(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        likeDidTapByUser(cell, indexPath: indexPath)
    }
}
