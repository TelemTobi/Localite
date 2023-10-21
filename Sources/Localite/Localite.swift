//
//  Localite.swift
//
//
//  Created by Telem Tobi on 21/10/2023.
//

import Foundation

public class Localite {
    
    public static let shared = Localite()
    
    internal var localiteBundle: Bundle?
    
    private var session = URLSession(configuration: .default)
    
    private var cacheFolderUrl: URL? {
        try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(String(describing: Localite.self).lowercased())
    }
    
    private init() {
        createCacheDirectoryIfNeeded()
        swizzleLocalization()
    }
    
    public func configure(using stringsFileUrl: URL, for language: String) {
        computeLocaliteBundle(for: language)
        fetchStringsFile(using: stringsFileUrl, for: language)
    }
    
    private func createCacheDirectoryIfNeeded() {
        if let cacheFolderUrl, !FileManager.default.fileExists(atPath: cacheFolderUrl.relativePath) {
            try? FileManager.default.createDirectory(atPath: cacheFolderUrl.relativePath, withIntermediateDirectories: false)
        }
    }
    
    private func computeLocaliteBundle(for language: String) {
        if let fileUrl = cacheFolderUrl?.appendingPathComponent(language) {
            localiteBundle = Bundle(path: fileUrl.relativePath)
        }
    }
    
    private func fetchStringsFile(using url: URL, for language: String) {
        session.dataTask(with: URLRequest(url: url)) { [unowned self] data, _, error in
            guard let data, error == nil else {
                debugPrint("Localite error - Fetching failed - " + (error?.localizedDescription ?? ""))
                return
            }
            
            do {
                try store(data, for: language)
            } catch(let error) {
                debugPrint("Localite error - File caching failed - " + error.localizedDescription)
            }
        }
        .resume()
    }
    
    private func store(_ data: Data, for language: String) throws {
        guard let cacheFolderUrl else { return }
        
        var fileUrl = cacheFolderUrl.appendingPathComponent(language)
        
        if !FileManager.default.fileExists(atPath: fileUrl.relativePath) {
            try FileManager.default.createDirectory(atPath: fileUrl.relativePath, withIntermediateDirectories: false)
        }
        
        fileUrl = fileUrl.appendingPathComponent("Localizable.strings")
        try data.write(to: fileUrl)
        
        computeLocaliteBundle(for: language)
        debugPrint("Localite - \(language) file loaded successfully")
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
