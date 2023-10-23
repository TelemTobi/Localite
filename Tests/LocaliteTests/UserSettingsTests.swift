import XCTest
@testable import Localite

final class UserSettingsTests: XCTestCase {
    
    private let userSettings = UserSettings()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        userSettings.clearVersions()
    }
    
    func testVersionsSetting() {
        userSettings.set(version: 1, for: "en")
        XCTAssertEqual(1, userSettings.getVersion(for: "en"))
        
        userSettings.set(version: 2, for: "en")
        XCTAssertEqual(2, userSettings.getVersion(for: "en"))
        
        userSettings.set(version: 3, for: "en")
        XCTAssertEqual(3, userSettings.getVersion(for: "en"))
        
        userSettings.set(version: 1, for: "he")
        XCTAssertEqual(1, userSettings.getVersion(for: "he"))
        XCTAssertEqual(3, userSettings.getVersion(for: "en"))
        
        userSettings.set(version: 2, for: "en")
        XCTAssertEqual(2, userSettings.getVersion(for: "en"))
    }
    
    func testClearVersionsMethod() {
        userSettings.set(version: 1, for: "en")
        userSettings.set(version: 2, for: "he")
        userSettings.set(version: 3, for: "ja")
        
        userSettings.clearVersions()
        XCTAssertEqual(0, userSettings.getVersion(for: "en"))
        XCTAssertEqual(0, userSettings.getVersion(for: "he"))
        XCTAssertEqual(0, userSettings.getVersion(for: "ja"))
    }
}
