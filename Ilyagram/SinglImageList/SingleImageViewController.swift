//
//  SingleImageViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 26.02.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var shareButton: UIButton!
    
    
    @IBAction private func didTapeBackward(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapeShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)
        
        present(share, animated: true, completion: nil)
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImageView.image = image
            guard let image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var largeImageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Set constrains
        setScrollViewConstrain()
        setShareButtonConstrain()
        setSingleImageViewConstrain()
        setBackButtonConstrain()
        
        singleImageView.image = image
        scrollViewSetup()
        downloadSingleImage()
        guard let image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func scrollViewSetup() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    private func setScrollViewConstrain() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setShareButtonConstrain() {
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 30),
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setSingleImageViewConstrain() {
        singleImageView.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubviewToFront(backButton)
        
        NSLayoutConstraint.activate([
            singleImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            singleImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            singleImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            singleImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
    }
    
    private func setBackButtonConstrain() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleContentSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleContentSize.height / imageSize.height
        let wScale = visibleContentSize.width / imageSize.width
        let scaleImageTemp = max(wScale, hScale)
        let scale = min(maxZoomScale, max(minZoomScale, scaleImageTemp))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleContentSize.width) / 2
        let y = (newContentSize.height - visibleContentSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        scrollView.layoutIfNeeded()
    }
}

extension SingleImageViewController {
    func downloadSingleImage() {
        UIBlockingProgressHUD.show()
        singleImageView.kf.setImage(with: largeImageURL) { [weak self] result in
            UIBlockingProgressHUD.dissmiss()
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                print("ERROR: SingleImageViewController -> downloadImage")
            }
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
}
