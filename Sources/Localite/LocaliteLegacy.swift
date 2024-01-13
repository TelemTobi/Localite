//
//  Localite+Legacy.swift
//
//
//  Created by Telem Tobi on 13/01/2024.
//

import Foundation

extension Localite {
    
    /**
     Initializes the Localite configuration.

     Use this method to set up Localite for a specific language.
     It loads strings files from the provided URL and stores them for offline using.
     If a version is provided, the file will only be fetched if the version is greater than the last fetched version. If no version is provided, the file will always be fetched.

     - Parameters:
       - stringsFileUrl: The URL from which to download the strings file. This URL can point to either a remote or local resource.
       - version (Optional): The version of the provided strings file. Versions are stored per language.
       - language: The currently selected language to load.
     */
    public func configure(stringsFileUrl: URL, forLanguage language: String, version: Int? = nil) {
        if shouldFetchStringsFile(of: version, for: language) {
            fetchStringsFile(using: stringsFileUrl, for: language) { [unowned self] data in
                store(data, version ?? 0, for: language)
            }
        } else {
            computeLocaliteBundle(for: language)
        }
    }
    
    /**
     Initializes the Localite configuration.

     Use this method to set up Localite, when your app supports only one language.
     It loads a strings file from the provided URL and stores it for offline using.

     - Parameters:
       - stringsFileUrl: The URL from which to download the strings file. This URL can point to either a remote or local resource.
     */
    public func configure(stringsFileUrl: URL, version: Int? = nil) {
        configure(stringsFileUrl: stringsFileUrl, forLanguage: "base", version: version)
    }
    
    /// Returns the last updated cached version for the provided language.
    public func cachedVersion(for language: String) -> Int {
        versionsStorage.getVersion(for: language)
    }
    
    internal func shouldFetchStringsFile(of version: Int?, for language: String) -> Bool {
        version == nil || (version ?? 0) > cachedVersion(for: language) || !filesStorage.fileExists(for: language)
    }
    
    private func computeLocaliteBundle(for language: String) {
        if let fileUrl = filesStorage.cachedFileUrl(for: language) {
            localiteBundle = Bundle(path: fileUrl.relativePath)
            print("Localite - Cached \(language) file loaded successfully")
        }
    }
    
    private func fetchStringsFile(using url: URL, for language: String, completion: @escaping (Data) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            guard let data, error == nil, (response as? HTTPURLResponse)?.statusCode ?? 0 < 400 else {
                print("Localite error - Fetching failed " + (error?.localizedDescription ?? ""))
                self?.computeLocaliteBundle(for: language)
                return
            }
            
            completion(data)
        }
        .resume()
    }
    
    private func store(_ data: Data, _ version: Int, for language: String) {
        do {
            try filesStorage.store(data, for: language)
            versionsStorage.set(version: version, for: language)
            computeLocaliteBundle(for: language)
            
        } catch(let error) {
            print("Localite error - File caching failed " + error.localizedDescription)
        }
    }
}
