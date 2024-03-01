# BandUp-IOS
## Installation
- Open project with Xcode
- Add a Secrets.swift file with the following content:
```swift
import Foundation

enum Secrets {
    static let baseApiURL = "http://localhost:9090/api/v1"
    static let s3BucketURL = "example aws"
}
```
- Pick a device/simulator on which to run the app
- Run the app
