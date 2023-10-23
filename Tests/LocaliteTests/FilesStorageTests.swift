import XCTest
@testable import Localite

final class FilesStorageTests: XCTestCase {
    
    private let filesStorage = FilesStorage()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        filesStorage.clear()
    }
    
    // TODO
}
