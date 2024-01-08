@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    let viewController = ImagesListViewController()
    let presenterSpy = ImagesListPresenterSpy()
    let viewControllerSpy = ImagesListViewControllerSpy()

    override func setUpWithError() throws {
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
    }
    
    func testViewControllerCallViewDidLoad() {
        _ = viewController.view
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testUpdatePhotos() {
        viewControllerSpy.updateTableViewAnimated([])
        
        XCTAssertTrue(viewControllerSpy.photosDidLoad)
        XCTAssertTrue(viewControllerSpy.countPhotos == 0)
    }
}
