# MRReachability

Lightweight reachability wrapper using `NWPathMonitor`, packaged for **Swift Package Manager (SPM)** and **CocoaPods**.

## Installation

### Swift Package Manager
- Xcode: **File → Add Packages…** → `https://github.com/<your-user>/MRReachability.git` (version: `1.0.0` or higher)

Or in `Package.swift`:
```swift
.package(url: "https://github.com/<your-user>/MRReachability.git", from: "1.0.0")
```

### CocoaPods
```ruby
pod 'MRReachability', '~> 1.0'
```

## Usage
```swift
import MRReachability

let reachability = MRReachability()
// Example: use your own API exposed by MRReachability.swift
```

## License
MIT
