# BandUp-IOS
## Installation
- Open project with Xcode
- Add a Secrets.swift file with the following enum:
```swift
import Foundation

enum Secrets {
    static let baseApiURL = "example url"
    static let s3BucketURL = "example aws bucket url"
}
```
!Note! if no aws s3 bucket url is specified (the static constant is an empty string), profile pictures won't be displayed but the app will run
- Pick a device/simulator on which to run the app
- Run the app
