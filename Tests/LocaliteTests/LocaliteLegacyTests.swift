import XCTest
@testable import Localite

final class LocaliteLegacyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Localite.shared.clearCache()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func configureLocalite(using stringsFileName: String, version: Int? = nil, for language: String = "base") {
        guard let bundlePath = Bundle.module.path(forResource: stringsFileName, ofType: "strings") else {
            XCTFail("Resource not found")
            return
        }

        let url = URL(fileURLWithPath: bundlePath)
        
        Localite.shared.configure(
            stringsFileUrl: url,
            forLanguage: language,
            version: version
        )
        
        sleep(1)
    }
    
    func testshouldFetchStringsFileMethod() {
        XCTAssertTrue(Localite.shared.shouldFetchStringsFile(of: nil, for: "en"))
        
        XCTAssertTrue(Localite.shared.shouldFetchStringsFile(of: 2, for: "en"))
        
        configureLocalite(using: "english", version: 2, for: "en")
        XCTAssertFalse(Localite.shared.shouldFetchStringsFile(of: 2, for: "en"))
        
        XCTAssertFalse(Localite.shared.shouldFetchStringsFile(of: 1, for: "en"))
    }
    
    func testLegacyConfigureMethod() {
        configureLocalite(using: "english", for: "en")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "Hello World")
        
        configureLocalite(using: "hebrew", for: "he")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "שלום עולם")
        
        configureLocalite(using: "japanese", for: "ja")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "こんにちは、 世界")
        
        configureLocalite(using: "base")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "Hello Base")
        
        // Make sure cached file is loaded on failed fetch
        Localite.shared.configure(
            stringsFileUrl: URL(string: "https://nonWorkingUrl.io")!,
            forLanguage: "en"
        )
        
        sleep(1)
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "Hello World")
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
