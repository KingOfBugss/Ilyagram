//
//  ViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 13.02.2024.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifire = "ShowSingleImage"
    private let photoName: [String] = Array(0..<20).map{"\($0)"}
    
    private lazy var dateFormater: DateFormatter = {
        let formater = DateFormatter()
        formater.dateStyle = .long
        formater.timeStyle = .none
        return formater
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifire {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: photoName[indexPath.row])
            viewController.image = image
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifire, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = UIImage(named: photoName[indexPath.row]) else {
            return 0
        }
        
        let insertPhoto = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - insertPhoto.left - insertPhoto.right
        let photoWidth = photo.size.width
        let scale = imageViewWidth / photoWidth
        let cellHeigth = photo.size.height * scale + insertPhoto.top + insertPhoto.bottom
        
        return cellHeigth
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = UIImage(named: photoName[indexPath.row]) else { return }
        
        cell.cellImage.image = photo
        cell.dateLabel.text = dateFormater.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let imageLiked = isLiked ? UIImage(named: "No Active") : UIImage(named: "Active")
        cell.likeButton.setImage(imageLiked, for: .normal)
    }
}
