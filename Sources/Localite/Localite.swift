//
//  Localite.swift
//
//
//  Created by Telem Tobi on 21/10/2023.
//

import Foundation

/// `Localite` is a lightweight localization package designed for the remote management of strings files.
public class Localite {
    
    /// Returns the shared `Localite` instance.
    public static let shared = Localite()
    
    internal var localiteBundle: Bundle?

    internal let filesStorage = FilesStorage()
    internal let versionsStorage = VersionsStorage()
    
    private init() {
        swizzleLocalization()
    }
    
    // TODO: Add a completion block letting the consumer know when the task completed
    // TODO: Doc && Test 👇
    public func configure(stringCatalogUrl: URL, version: Int? = nil) {
        if shouldFetchCatalogFile(of: version) {
            fetchCatalogFile(using: stringCatalogUrl) { [unowned self] data in
                store(data, with: version ?? 0)
            }
        } else {
            computeLocaliteBundle()
        }
    }

    // TODO: Doc && Test 👇
    public var catalogCachedVersion: Int {
        versionsStorage.cachedCatalogVersion
    }
    
    ///  Clears Localite's cache, including any cached strings files and content.
    public func clearCache() {
        localiteBundle = nil
        filesStorage.clear()
        versionsStorage.clear()
    }
    
    internal func shouldFetchCatalogFile(of version: Int?) -> Bool {
        version == nil || (version ?? 0) > catalogCachedVersion || !filesStorage.catalogFileExists
    }
    
    private func computeLocaliteBundle() {
        if let fileUrl = filesStorage.cachedCatalogFileUrl {
            localiteBundle = Bundle(path: fileUrl.relativePath)
            print("Localite - Cached catalog file loaded successfully")
        }
    }
    
    private func fetchCatalogFile(using url: URL, completion: @escaping (Data) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            guard let data, error == nil, (response as? HTTPURLResponse)?.statusCode ?? 0 < 400 else {
                print("Localite error - Fetching failed " + (error?.localizedDescription ?? ""))
                self?.computeLocaliteBundle()
                return
            }
            
            completion(data)
        }
        .resume()
    }
    
    private func store(_ data: Data, with version: Int) {
        do {
            try filesStorage.storeCatalog(data)
            versionsStorage.setCatalogVersion(version)
            computeLocaliteBundle()
            
        } catch(let error) {
            print("Localite error - File caching failed " + error.localizedDescription)
        }
    }
    
    private func swizzleLocalization() {
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let overrideSelector = #selector(Bundle.localiteString(forKey:value:table:))
        
        guard let originalMethod: Method = class_getInstanceMethod(Bundle.self, originalSelector),
              let overrideMethod: Method = class_getInstanceMethod(Bundle.self, overrideSelector)
        else { return }
        
        if class_addMethod(Bundle.self, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)) {
            class_replaceMethod(Bundle.self, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, overrideMethod)
        }
    }
}

extension Bundle {
    
    @objc func localiteString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle = Localite.shared.localiteBundle ?? Bundle.main
        return bundle.localiteString(forKey: key, value: value, table: tableName)
    }
}
