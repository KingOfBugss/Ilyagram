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

public final class ImagesListCell: UITableViewCell {
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    let placeholderImage = UIImage(named: "Stub")
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        setLiked(false)
        cellImage.kf.cancelDownloadTask()
    }
    
    @IBAction private func likeButtonIsTap(_ sender: Any) {
        delegate?.likeDidTapByUser(self)
    }
    
    func setLiked(_ isLiked: Bool) {
        let imageLiked = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        likeButton.setImage(imageLiked, for: .normal)
    }
    
    func loadCell(from photo: Photo) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var status = false
        if let photoDate = photo.createdAt {
            dateLabel.text = formatter.string(from: photoDate)
        }
        likeButton.accessibilityIdentifier = "LikeButton"
        setLiked(photo.isLiked)
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
