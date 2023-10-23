import XCTest
@testable import Localite

final class LocaliteTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        Localite.shared.clearCache()
    }
    
    private func configureLocalite(using stringsFileName: String, version: Int? = nil, for language: String) {
        guard let bundlePath = Bundle.module.path(forResource: stringsFileName, ofType: "strings") else {
            XCTFail("Resource not found")
            return
        }

        let url = URL(fileURLWithPath: bundlePath)
        
        Localite.shared.configure(using: url, version: version, for: language)
        sleep(1)
    }
    
    func testshouldFetchStringsFileMethod() {
        XCTAssertTrue(Localite.shared.shouldFetchStringsFile(of: nil, for: "en"))
        
        XCTAssertTrue(Localite.shared.shouldFetchStringsFile(of: 2, for: "en"))
        
        configureLocalite(using: "english", version: 2, for: "en")
        XCTAssertFalse(Localite.shared.shouldFetchStringsFile(of: 2, for: "en"))
        
        XCTAssertFalse(Localite.shared.shouldFetchStringsFile(of: 1, for: "en"))
    }
    
    func testConfigureMethod() {
        configureLocalite(using: "english", for: "en")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "Hello World")
        
        configureLocalite(using: "hebrew", for: "he")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "שלום עולם")
        
        configureLocalite(using: "japanese", for: "ja")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "こんにちは、 世界")
    }
    
    func testCachedVersionMethod() {
        configureLocalite(using: "english", for: "en")
        XCTAssertEqual(0, Localite.shared.cachedVersion(for: "en"))
        
        configureLocalite(using: "english", version: 1, for: "en")
        XCTAssertEqual(1, Localite.shared.cachedVersion(for: "en"))
        
        configureLocalite(using: "hebrew", for: "he")
        XCTAssertEqual(0, Localite.shared.cachedVersion(for: "he"))
        
        configureLocalite(using: "hebrew", version: 5, for: "he")
        XCTAssertEqual(5, Localite.shared.cachedVersion(for: "he"))
    }
    
    func testClearCacheMethod() {
        configureLocalite(using: "english", version: 1, for: "en")
        configureLocalite(using: "japanese", version: 5, for: "ja")
        Localite.shared.clearCache()
        
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "Hello")
        XCTAssertEqual(0, Localite.shared.cachedVersion(for: "en"))
        XCTAssertEqual(0, Localite.shared.cachedVersion(for: "ja"))
    }
}
