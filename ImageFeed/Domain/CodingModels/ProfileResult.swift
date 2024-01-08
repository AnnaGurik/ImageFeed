import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

public struct Profile {
    public let username: String
    public let name: String
    public let loginName: String
    public let bio: String
    
    init(profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = profileResult.firstName + profileResult.lastName
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio ?? ""
    }
    
    public init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
}
