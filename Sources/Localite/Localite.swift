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
    internal let urlSession = URLSession(configuration: .default)
    
    private init() {
        swizzleLocalization()
    }
    
    ///  Clears Localite's cache, including any cached strings files and content.
    public func clearCache() {
        localiteBundle = nil
        filesStorage.clear()
        versionsStorage.clear()
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
