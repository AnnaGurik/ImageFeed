import UIKit

extension UIViewController {
    func showAlert(title: String, description: String?) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .cancel)
        alert.addAction(okAction)
        
        self.show(alert, sender: nil)
    }
}

extension UIViewController {
    func showError(retry: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Что-то пошло не так", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            retry?()
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        self.show(alert, sender: nil)
    }
}

extension UIViewController {
    func showLogoutAlert(action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Вы уверены, что хотите выйти?", message: nil, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Выход", style: .destructive) { _ in
            action?()
        }
        let closeAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(logoutAction)
        alert.addAction(closeAction)
        
        self.show(alert, sender: nil)
    }
}
