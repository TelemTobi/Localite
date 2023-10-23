//
//  FilesStorage.swift
//
//
//  Created by Telem Tobi on 23/10/2023.
//

import Foundation

class FilesStorage {
    
    private var cacheDirectoryUrl: URL? {
        try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(String(describing: Localite.self).lowercased())
    }
    
    init() {
        createCacheDirectoryIfNeeded()
    }
    
    private func createCacheDirectoryIfNeeded() {
        if let cacheDirectoryUrl, !FileManager.default.fileExists(atPath: cacheDirectoryUrl.relativePath) {
            try? FileManager.default.createDirectory(atPath: cacheDirectoryUrl.relativePath, withIntermediateDirectories: false)
        }
    }
    
    func store(_ data: Data, for language: String) throws {
        guard let cacheDirectoryUrl else { return }
        
        var fileUrl = cacheDirectoryUrl.appendingPathComponent(language)
        
        if !FileManager.default.fileExists(atPath: fileUrl.relativePath) {
            try FileManager.default.createDirectory(atPath: fileUrl.relativePath, withIntermediateDirectories: false)
        }
        
        fileUrl = fileUrl.appendingPathComponent("Localizable.strings")
        try data.write(to: fileUrl)
    }
    
    func fileExists(for language: String) -> Bool {
        FileManager.default.fileExists(atPath: cacheDirectoryUrl?.appendingPathComponent(language).relativePath ?? "")
    }
    
    func cachedFileUrl(for language: String) -> URL? {
        if let fileUrl = cacheDirectoryUrl?.appendingPathComponent(language),
           FileManager.default.fileExists(atPath: fileUrl.relativePath) {
            return fileUrl
        }
        
        return nil
    }
    
    func clear() {
        if let cacheDirectoryUrl {
            try? FileManager.default.removeItem(at: cacheDirectoryUrl)
            createCacheDirectoryIfNeeded()
        }
    }
}
