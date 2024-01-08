import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let launchImage: UIImageView = {
        let image = UIImage(named: "LaunchImage")
        
        return UIImageView(image: image)
    }()
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        addSubviews()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2TokenStorage.token {
            UIBlockingProgressHUD.show()
            self.fetchProfile(token: token)
        } else {
            showAuthView()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func addSubviews() {
        launchImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchImage)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            launchImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    private func showAuthView() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            switch result {
            case .success(let token):
                self?.fetchProfile(token: token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self?.showAlert(title: "Не удалось войти в систему", description: nil)
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username, {_ in})
                UIBlockingProgressHUD.dismiss()
                self?.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self?.showAlert(title: "Что-то пошло не так", description: nil)
                break
            }
        }
    }
}
