@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    let viewController = ProfileViewController()
    let viewControllerSpy = ProfileViewControllerSpy()
    let presenterSpy = ProfilePresenterSpy()

    override func setUpWithError() throws {
        viewController.presenter = presenterSpy
        presenterSpy.view = viewControllerSpy
    }
    
    func testViewControllerCallViewDidLoad() {
        _ = viewController.view
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testLoadProfile() {
        let profile = Profile(profileResult: ProfileResult(username: "anich", firstName: "Anna", lastName: "@anich", bio: "Что-то"))
        viewControllerSpy.updateData(profile: profile)
        
        XCTAssertTrue(viewControllerSpy.viewDidLoadProfile)
    }
    
    func testAvatart() {
        viewControllerSpy.updateAvatar(URL(string: "https://www.google.com/")!)
        
        XCTAssertTrue(viewControllerSpy.viewDidUpdateAvatar)
    }
}
