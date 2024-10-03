//
//  ProfileViewController.swift
//  Ilyagram
//
//  Created by Ilya Shirokov on 20.02.2024.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
  func loadProfile(_ profile: Profile?)
}

final class ProfileViewController: UIViewController {
    
    private let backButtonImage = UIImage(named: "LogoutButton")
    private let avatarImage = UIImage(named: "ProfilePhoto")
    private let placeholder = UIImage(named: "PlaceHolderForAvatar")
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let logOutService = LogOutService.shared
    
    private var alertPresenter: AlertPresenterProtocol?
    private lazy var backButtonImageView = UIImageView()
    private lazy var imageAvatarView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var loginNameLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var tokenInStorage: AuthTokenStorageProtocol = AccessKeyStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(viewController: self)
        subscribe()
        fetchProfile(token: tokenInStorage.token ?? "")
        makeProfilePhotoImage()
        makeNameLabel()
        makeLoginNameLabel()
        makeDescriptionLabel()
        makeLogoutButton()
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification,
                                               object: self,
                                               queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.checkAvatar()
        }
    }
    
    private func updateAvatar(url: URL) {
        
        //MARK: Kingfisher
        imageAvatarView.kf.indicatorType = .activity
        imageAvatarView.kf.setImage(with: url, placeholder: placeholder)
    }
    
    func updateProfile() {
        guard let updateProfile = profileService.profile else { return }
        loadProfile(updateProfile)
    }
    
    func checkAvatar() {
        if let url = ProfileImageService.shared.avatarURL {
            updateAvatar(url: url)
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile { [weak self] profileResult in
            switch profileResult {
            case .success(let profile):
                let username = profile.username
                self?.fetchProfileImage(profileUsername: username)
                self?.updateProfile()
            case .failure(let error):
                print("ERROR: \(error) in ProfileViewController -> fetchProfile")
                UIBlockingProgressHUD.dissmiss()
            }
        }
    }
    
    private func fetchProfileImage(profileUsername: String) {
        profileImageService.fetchProfileImageURL(username: profileUsername) { [weak self] profileImageUrl in
            guard let self else { return }
            switch profileImageUrl {
            case .success:
                checkAvatar()
                UIBlockingProgressHUD.dissmiss()
            case .failure(let error):
                print("ERROR:\(error) case .failure in fetchProfileImage")
                break
            }
        }
    }
    
    @objc private func didTapBackButton() {
        showLogoutAlert()
    }
    
    private func showLogoutAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let alertModel = AlertModel(
                title: "Пока, пока!",
                message: "Уверены, что хотите выйти?",
                buttonText: "Да",
                completion: { self.accountReset() },
                secondButtonText: "Нет",
                secondCompletion: { self.dismiss(animated: true) }
            )
            alertPresenter?.showAlert(for: alertModel)
        }
    }
    
    func accountReset(){
        logOutService.resetToken()
        logOutService.cleanCookie()
        logOutService.resetPhotos()
        logOutService.resetView()
        //         Старая версия перехода(ошибка при новом входе после разлогина)
        //        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        //        let toAuthVc = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        //        guard let toAuthVc = toAuthVc else { return }
        //        toAuthVc.delegate = self
        //        let navigationController = UINavigationController(rootViewController: toAuthVc)
        //        navigationController.modalPresentationStyle = .fullScreen
        //        self.navigationController?.pushViewController(navigationController, animated: true)
        //        present(navigationController, animated: true)
        
        guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}

extension ProfileViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
    }
    
    func makeProfilePhotoImage() {
        imageAvatarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageAvatarView)
        
        imageAvatarView.image = avatarImage
        
        NSLayoutConstraint.activate([
            imageAvatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageAvatarView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            imageAvatarView.widthAnchor.constraint(equalToConstant: 70),
            imageAvatarView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func makeNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: imageAvatarView.bottomAnchor, constant: 8)
        ])
    }
    
    func makeLoginNameLabel() {
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.widthAnchor.constraint(equalTo: nameLabel.widthAnchor),
            loginNameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    func makeDescriptionLabel() {
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.widthAnchor.constraint(equalTo: loginNameLabel.widthAnchor),
            descriptionLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    func makeLogoutButton() {
        backButtonImageView.image = backButtonImage
        let logoutButton = UIButton.systemButton(with: backButtonImage!, //FAST UWRAPED!!!!
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
    
    func loadProfile(_ profile: Profile?) {
        
        if let profile {
            self.nameLabel.text = profile.username
            self.loginNameLabel.text = profile.loginName
            self.descriptionLabel.text = profile.bio
        } else {
            self.nameLabel.text = ""
            self.loginNameLabel.text = ""
            self.descriptionLabel.text = ""
            self.imageAvatarView.image = placeholder
        }
    }
}
