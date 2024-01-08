import Foundation
import SwiftKeychainWrapper
import WebKit

final class OAuth2TokenStorage {
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "token")
        }
        
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "token")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "token")
            }
        }
    }
    
    static func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                 WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
              }
        }
        
        OAuth2TokenStorage().token = nil
    }
}
