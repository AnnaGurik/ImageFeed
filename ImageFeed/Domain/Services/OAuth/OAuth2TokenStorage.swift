import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "token")
        }
        
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "token")
            }
        }
    }
}
