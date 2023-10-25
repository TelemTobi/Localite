import XCTest
@testable import Localite

final class FilesStorageTests: XCTestCase {
    
    private let filesStorage = FilesStorage()
    private let urlSession = URLSession(configuration: .default)
    
    override func setUp() {
        super.setUp()
        filesStorage.clear()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func getData(for stringsFileName: String, completion: @escaping (Data) -> Void) {
        guard let bundlePath = Bundle.module.path(forResource: stringsFileName, ofType: "strings") else {
            XCTFail("Resource not found")
            return
        }
        
        let url = URL(fileURLWithPath: bundlePath)
        
        urlSession.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data, error == nil else {
                XCTFail("Fetching failed")
                return
            }
            
            completion(data)
        }
        .resume()
    }
    
    private func storeData(fileName: String, language: String) {
        getData(for: fileName) { [weak self] data in
            guard let self else { return }
            
            try? filesStorage.store(data, for: language)
        }
        sleep(1)
    }
    
    func testStoreMethod() {
        XCTAssertFalse(filesStorage.fileExists(for: "en"))
        XCTAssertFalse(filesStorage.fileExists(for: "he"))
        XCTAssertFalse(filesStorage.fileExists(for: "ja"))
        
        storeData(fileName: "english", language: "en")
        XCTAssertTrue(filesStorage.fileExists(for: "en"))
        
        storeData(fileName: "hebrew", language: "he")
        XCTAssertTrue(filesStorage.fileExists(for: "he"))
        
        storeData(fileName: "japanese", language: "ja")
        XCTAssertTrue(filesStorage.fileExists(for: "ja"))
        
        XCTAssertFalse(filesStorage.fileExists(for: "someOtherLanguage"))
    }
    
    func testCachedFileUrlMethod() {
        XCTAssertNil(filesStorage.cachedFileUrl(for: "en"))
        XCTAssertNil(filesStorage.cachedFileUrl(for: "he"))
        XCTAssertNil(filesStorage.cachedFileUrl(for: "ja"))
        
        storeData(fileName: "english", language: "en")
        
        let enFileUrl = filesStorage.cachedFileUrl(for: "en")
        XCTAssertNotNil(enFileUrl)
        XCTAssertEqual("en", enFileUrl?.lastPathComponent)
        
        storeData(fileName: "japanese", language: "ja")
        
        let jaFileUrl = filesStorage.cachedFileUrl(for: "ja")
        XCTAssertNotNil(jaFileUrl)
        XCTAssertEqual("ja", jaFileUrl?.lastPathComponent)
    }
    
    func testClearMethod() {
        storeData(fileName: "english", language: "en")
        
        filesStorage.clear()
        XCTAssertFalse(filesStorage.fileExists(for: "en"))
        
        storeData(fileName: "hebrew", language: "he")
        storeData(fileName: "japanese", language: "ja")
        
        filesStorage.clear()
        
        XCTAssertFalse(filesStorage.fileExists(for: "he"))
        XCTAssertFalse(filesStorage.fileExists(for: "ja"))
    }
}
