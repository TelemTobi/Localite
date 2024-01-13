//
//  VersionsStorage.swift
//
//
//  Created by Telem Tobi on 23/10/2023.
//

import Foundation

class VersionsStorage {
    
    enum Keys {
        static let versions = #function
    }
    
    private let localiteSuite = UserDefaults(suiteName: String(describing: Localite.self).lowercased())

    func clear() {
        localiteSuite?.removeObject(forKey: Keys.versions)
    }
    
    // MARK: - String catalog file
    
    // TODO: Test 👇
    var cachedCatalogVersion: Int {
        0 // TODO: ⚠️
    }
    
    // TODO: Test 👇
    func setCatalogVersion(_ version: Int) {
        // TODO: ⚠️
    }
    
    // MARK: - Legacy strings files
    
    func set(version: Int, for language: String) {
        var versions = localiteSuite?.dictionary(forKey: Keys.versions) as? [String : Int] ?? [String : Int]()
        versions[language] = version
        localiteSuite?.setValue(versions, forKey: Keys.versions)
    }
    
    func getVersion(for language: String) -> Int {
        let versions = localiteSuite?.dictionary(forKey: Keys.versions) as? [String : Int]
        return versions?[language] ?? 0
    }
}
