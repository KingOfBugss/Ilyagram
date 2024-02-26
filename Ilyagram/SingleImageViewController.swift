//
//  SingleImageViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 26.02.2024.
//

import Foundation
import UIKit

class SingleImageViewController: UIViewController {
    var image: UIImage?
    
    @IBOutlet var singleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleImageView.image = image
    }
}
