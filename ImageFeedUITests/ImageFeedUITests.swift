import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    enum TestCreds {
      static let email = "email"
      static let pwd = "password"
      static let name = "full name"
      static let login = "@login"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()

    }
    
    func testAuth() {
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 3))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 3))

        loginTextField.tap()
        loginTextField.typeText(TestCreds.email)
        webView.tap()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 3))

        passwordTextField.tap()
        passwordTextField.typeText(TestCreds.pwd)
        webView.tap()
        sleep(3)

        XCTAssertTrue(webView.buttons["Login"].waitForExistence(timeout: 3))
        webView.buttons["Login"].tap()


        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 0).waitForExistence(timeout: 3))

        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 3))
        cell.swipeDown()
        sleep(2)

        let cellTwo = tableQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cell.waitForExistence(timeout: 3))
        XCTAssertTrue(cell.buttons["LikeButton"].waitForExistence(timeout: 1))
        cellTwo.buttons["LikeButton"].tap()
        sleep(3)
        cellTwo.buttons["LikeButton"].tap()
        sleep(3)

        cellTwo.tap()
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        XCTAssertTrue(app.buttons["BackButton"].waitForExistence(timeout: 3))
        app.buttons["BackButton"].tap()
    }

    func testProfile() throws {
      XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 3))
      app.tabBars.buttons.element(boundBy: 1).tap()

      XCTAssertTrue(app.buttons["logoutButton"].waitForExistence(timeout: 3))
      XCTAssertTrue(app.staticTexts[TestCreds.name].exists)
      XCTAssertTrue(app.staticTexts[TestCreds.login].exists)

      app.buttons["logoutButton"].tap()

      XCTAssertTrue(app.alerts["Alert"].waitForExistence(timeout: 3))
      app.alerts["Alert"].buttons["Да"].tap()

      XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
    }
}
