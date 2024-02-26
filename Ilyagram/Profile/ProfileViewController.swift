//
//  ProfileViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 20.02.2024.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!

    @IBAction func didTapeLogoutButton() {
    }
}
