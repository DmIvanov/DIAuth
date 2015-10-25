# DIAuth

[![CI Status](http://img.shields.io/travis/Dmitry Ivanov/DIAuth.svg?style=flat)](https://travis-ci.org/Dmitry Ivanov/DIAuth)
[![Version](https://img.shields.io/cocoapods/v/DIAuth.svg?style=flat)](http://cocoapods.org/pods/DIAuth)
[![License](https://img.shields.io/cocoapods/l/DIAuth.svg?style=flat)](http://cocoapods.org/pods/DIAuth)
[![Platform](https://img.shields.io/cocoapods/p/DIAuth.svg?style=flat)](http://cocoapods.org/pods/DIAuth)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0+

## Installation

###Manualy

You can integrate DIAuth into your project manually as a submodule. Core files are in (DIAuth/tree/master/DIAuth/DIAuth)

###Cocoapods

Now we have some issues connected with interactions between DIAuth as a pod, FBSDK and Bolts.framework (DIAuth dependensies). It looks like the SO issue http://stackoverflow.com/questions/29435377/facebook-ios8-sdk-build-module-error-for-fbsdkcorekit but all of those solutions didn't help with DIAuth pod.

~~DIAuth is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:~~

```ruby
pod "DIAuth"
```


## Author

Dmitry Ivanov, topolog@icloud.com

## License

DIAuth is available under the MIT license. See the LICENSE file for more info.
