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
    
    private func configureLocalite(using stringsFileName: String, for language: String) {
        guard let bundlePath = Bundle.module.path(forResource: stringsFileName, ofType: "strings") else {
            XCTFail("Resource not found")
            return
        }
        
        let url = URL(fileURLWithPath: bundlePath)
        Localite.shared.configure(using: url, for: language)
        sleep(1)
    }
    
    func testClearCacheMethod() {
        configureLocalite(using: "english", for: "en")
        Localite.shared.clearCache()
        
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "Hello")
    }
    
    func testConfigureMethod() {
        configureLocalite(using: "english", for: "en")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "Hello World")
        
        configureLocalite(using: "hebrew", for: "he")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "שלום עולם")
        
        configureLocalite(using: "japanese", for: "ja")
        XCTAssertEqual(NSLocalizedString("Hello", comment: ""), "こんにちは、 世界")
    }
}
