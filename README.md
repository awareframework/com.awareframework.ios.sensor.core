# AWARE: Core 

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Overview
com.awareframework.ios.sensor.core provides a basic class for developing your own sensor module on aware framework.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 13 or later.


## Installation

You can integrate this framework into your project via Swift Package Manager (SwiftPM) or CocoaPods.

### SwiftPM
1. Open Package Manager Windows
    * Open `Xcode` -> Select `Menu Bar` -> `File` -> `App Package Dependencies...` 

2. Find the package using the manager
    * Select `Search Package URL` and type `git@github.com:awareframework/com.awareframework.ios.sensor.core.git`

3. Import the package into your target.


### CocoaPods
com.aware.ios.sensor.core is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'com.awareframework.ios.sensor.core'
```

### Extending to a new AWARE module
1. Make a subclass of AwareSensor as a sensor module
2. Extende SensorConfig for adding originl parameters 
3. Store data using the provided database engine
4. Sync local-database with remote-database

## Author
Yuuki Nishiyama, nishiyama@csis.u-tokyo.ac.jp

## License
Copyright (c) 2014 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
