import UIKit

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func cleanAndLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        loadProfile()
        profileImageServiceObserver = NotificationCenter.default
        .addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.getUrlForAvatar()
        }
        getUrlForAvatar()
    }
    
    func cleanAndLogout() {
        OAuth2TokenStorage.clean()
        
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
    
    private func getUrlForAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.updateAvatar(url)
    }
    
    private func loadProfile() {
        guard let profile = profileService.profile else { return }
        view?.updateData(profile: profile)
    }
}
