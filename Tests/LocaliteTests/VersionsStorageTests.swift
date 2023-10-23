import XCTest
@testable import Localite

final class VersionsStorageTests: XCTestCase {
    
    private let versionsStorage = VersionsStorage()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        versionsStorage.clear()
    }
    
    func testVersionsSetting() {
        versionsStorage.set(version: 1, for: "en")
        XCTAssertEqual(1, versionsStorage.getVersion(for: "en"))
        
        versionsStorage.set(version: 2, for: "en")
        XCTAssertEqual(2, versionsStorage.getVersion(for: "en"))
        
        versionsStorage.set(version: 3, for: "en")
        XCTAssertEqual(3, versionsStorage.getVersion(for: "en"))
        
        versionsStorage.set(version: 1, for: "he")
        XCTAssertEqual(1, versionsStorage.getVersion(for: "he"))
        XCTAssertEqual(3, versionsStorage.getVersion(for: "en"))
        
        versionsStorage.set(version: 2, for: "en")
        XCTAssertEqual(2, versionsStorage.getVersion(for: "en"))
    }
    
    func testClearVersionsMethod() {
        versionsStorage.set(version: 1, for: "en")
        versionsStorage.set(version: 2, for: "he")
        versionsStorage.set(version: 3, for: "ja")
        
        versionsStorage.clear()
        XCTAssertEqual(0, versionsStorage.getVersion(for: "en"))
        XCTAssertEqual(0, versionsStorage.getVersion(for: "he"))
        XCTAssertEqual(0, versionsStorage.getVersion(for: "ja"))
    }
}
