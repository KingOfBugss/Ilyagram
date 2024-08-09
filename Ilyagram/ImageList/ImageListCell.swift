//
//  ImageListCell.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 17.02.2024.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func likeDidTapByUser(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    let placeholderImage = UIImage(named: "Stub")
    
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    @IBAction private func likeButtonIsTap(_ sender: Any) {
        delegate?.likeDidTapByUser(self)
    }
    
    func loadCell(from photo: Photo) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        var status = false
        if let photoDate = photo.createdAt {
          dateLabel.text = formatter.string(from: photoDate)
        }
        likeButton.accessibilityIdentifier = "LikeButton"
        
        guard let photoURL = URL(string: photo.thumbImageURL) else { return status }
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: photoURL, placeholder: placeholderImage) { [weak self] result in
          guard let self else { return }
          switch result {
          case .success:
            status = true
          case .failure(let error):
            cellImage.image = placeholderImage
            print("ERROR: \(error.localizedDescription)")
          }
        }
        return status
    }
}
