<p align="center">
  <img height="180" src="Resources/localite_logo.png">
</p>

**Localite** is a lightweight localization package for iOS that simplifies the remote management of strings files. <br/>
It allows you to download and cache localization files from a remote server, <br/>
making it easier to keep your app's localization up to date without requiring frequent app updates.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FTelemTobi%2FLocalite%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/TelemTobi/Localite)   [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FTelemTobi%2FLocalite%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/TelemTobi/Localite)

## Features

- Remote fetching and caching of strings files.
- Efficient version management for localization files.
- Support for multiple languages.

## Installation

### Swift Package Manager

You can use Swift Package Manager to integrate **Localite** into your Xcode project. 

In Xcode, go to `File` > `Swift Packages` > `Add Package Dependency` and enter the repository URL:

```
https://github.com/TelemTobi/Localite.git
```

## Usage

### Initialization

Initialize the **Localite** configuration by setting up your app to use a specific language and providing a URL for the strings file.

```swift
import Localite

// Get the first language in user's preferred langauges your app supports
Localite.shared.configure(using: yourStringsFileURL, for: "en", version: 1)
```

Or, when your app supports only one language:

```swift
// Initialize Localite for a single language
Localite.shared.configure(using: yourStringsFileURL)
```

The file will be cached for offline mode support.

### Fetching and Using Strings

Once Localite is configured, you can access localized strings using the standard NSLocalizedString function. <br/>
Localite will automatically fetch the strings file from the provided URL, cache it, and use it for localization.

```swift
let localizedString = NSLocalizedString("hello_key", comment: "")
```

### Version Management

**Localite** provides version management for localization files. <br/>
When you initialize **Localite** with a version number, it will only fetch the file if the version is greater than the last fetched version. <br/>
If no version is provided, the file will always be fetched.

You can also check the cached version for a specific language:

```swift
let cachedVersion = Localite.shared.cachedVersion(for: "en")
```

### Clearing Cache
To clear the **Localite** cache, including cached strings files and content, use the clearCache method:

```swift
Localite.shared.clearCache()
```

## Requirements

- iOS 11.0+
- Xcode 12.0+
- Swift 5.7+

## License

**Localite** is available under the MIT license. See the [LICENSE](https://github.com/TelemTobi/Localite/blob/main/LICENSE.txt) file for more information.

## Contributing

We encourage and welcome contributions from the community. <br/>
If you'd like to contribute to the development of **Localite**, please feel free to get involved. <br/>
You can start by:

- **Reporting Issues**: If you encounter any bugs or have suggestions for improvements, please open an issue.
- **Submitting Pull Requests**: If you'd like to contribute code or enhancements, you can submit a pull request. We'll review your contributions and work together to integrate them into the project.

Your involvement is highly appreciated, and it helps make Localite even better. Thank you for considering contributing!
