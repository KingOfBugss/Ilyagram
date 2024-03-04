//
//  ProfileViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 20.02.2024.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!

    @IBAction private func didTapeLogoutButton() {
    }
}
