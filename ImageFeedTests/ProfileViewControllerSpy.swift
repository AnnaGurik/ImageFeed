import UIKit
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var viewDidUpdateAvatar = false
    var viewDidLoadProfile = false
    var presenter: ProfilePresenterProtocol?
    
    var userNameLabel = UILabel()
    var loginLabel = UILabel()
    var descriptionLabel = UILabel()
    
    func updateAvatar(_ url: URL) {
        viewDidUpdateAvatar = true
    }
    
    func updateData(profile: Profile) {
        userNameLabel.text = profile.username
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
        viewDidLoadProfile = true
    }
    
}
