//
//  ProfileViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 20.02.2024.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBAction private func didTapeLogoutButton() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let avatarImage = UIImage(named: "ProfilePhoto")
        let imageAvatarView = UIImageView(image: avatarImage)

        imageAvatarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageAvatarView)
        
        NSLayoutConstraint.activate([
            imageAvatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageAvatarView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            imageAvatarView.widthAnchor.constraint(equalToConstant: 70),
            imageAvatarView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor.white
        UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: imageAvatarView.bottomAnchor, constant: 8)
        ])
        
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        UIFont.systemFont(ofSize: 13, weight: .medium)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
            loginNameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor.white
        UIFont.systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.widthAnchor.constraint(equalTo: loginNameLabel.widthAnchor),
            descriptionLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
        
        let backButtonImage = UIImage(named: "LogoutButton")
        let logoutButton = UIButton.systemButton(with: backButtonImage!,
                                                 target: self,
                                                 action: #selector(self.didTapBackButton))

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: imageAvatarView.centerYAnchor)])
    }
    
    @objc private func didTapBackButton() {
        
    }
}
