# DIAuth

[![CI Status](http://img.shields.io/travis/Dmitry Ivanov/DIAuth.svg?style=flat)](https://travis-ci.org/Dmitry Ivanov/DIAuth)
[![Version](https://img.shields.io/cocoapods/v/DIAuth.svg?style=flat)](http://cocoapods.org/pods/DIAuth)
[![License](https://img.shields.io/cocoapods/l/DIAuth.svg?style=flat)](http://cocoapods.org/pods/DIAuth)
[![Platform](https://img.shields.io/cocoapods/p/DIAuth.svg?style=flat)](http://cocoapods.org/pods/DIAuth)

 DIAuth is authorization system for two step authorization: social network auth + own server auth (optional). It's usefull for login into your app via social app account (OAuth). It wraps social network authorization, serves as a facade for different auth-services and provide one authorization interface and a solid workflow for whole authorization process. DIAuth manage caching social network account via native instruments of social network SDK's or via store account data into keychain.
 
 There are just couple social networks inside:
 - Facebook
 - VKontakte
 
You can easily make your own class for authorising inside the system (see [usage](#usage))

## Usage

### Authorization Status
All the authorization process is displayed by auth-status
```swift
DIAuth.sharedInstance.status
```

You can process the status changing by observing it in `NSNotificationCenter`
```swift
NSNotificationCenter.defaultCenter().addObserver(self, selector: "authStatusDidChange:", name: kDIAuthStatusDidChangeNotification, object: nil)

@objc func authStatusDidChange(notification: NSNotification) {
        if let rawStatus = notification.userInfo?[kDIAuthStatusDidChangeNewStatusKey] as? String {
            if let status = DIAuthStatus(rawValue: rawStatus) {
                processAuthStatusChanging(status)
            }
        }
    }
```

### Authorization
Use this DIAuth singleton method for starting auth process
```swift
func start(socialNetwork: DISocialNetwork?, newConnector:DIAuthConnector)
```
First parameter is social network instance (child of DISocialNetwork class) or nil. Second one is your `DIAuthConnector` implementer that will be used for taking settings during auth process and for callback when social authorization is finished.

Start DIAuth when your app has launched
```swift
func appLaunchedWithOptions(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
    DIAuth.sharedInstance.start(nil, newConnector: connector)
}
```
If you pass `nil` as the first parameter, DIAuth will check cached social network authorization first. If there isn't anything in the cache, auth-status will change to `WaitingForUser`.

When user has started authorization with specific social network type (fb, vk or other), you should call start method with social network instance (you just need to init it, all the customization will be done inside DIAuth with a help of your `DIAuthConnector` implementer)
```swift
func fbLoginButtonPressed() {
    DIAuth.sharedInstance.start(DIFacebook(), newConnector: connector)
}
```

Call logOut method when user logs out from your app account. DIAuth will log out from social network and clean cache data.
```swift
DIAuth.sharedInstance.logOut()
```
Otherwise next time launching your app DIAuth will use cached social network account.

### AppDelegate methods
Call DIAuth from your appDelegate to pass it some app events
```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) {
    DIAuth.sharedInstance.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
}
    
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
    DIAuth.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
}
    
func applicationDidBecomeActive(application: UIApplication) {
    DIAuth.sharedInstance.applicationDidBecomeActive(application)
}
```

### Custom Social Networks
If you want additional authorization option (different social network, your own e-mail authorization,...) just add an appropriare `DISocialNetwork` child class, implement some necessary methods in it and pass it into DIAuth start (like `DIFacebook`, `DIVKontakte`)
```swift
class YourCustomSocialNetwork: DISocialNetwork {

    //MARK: Events from appDelegate
    override func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        //override if necessary
    }
    
    override func applicationDidBecomeActive(application: UIApplication) {
        //override if necessary
    }
    
    
    //MARK:
    override func resetAuthData() {
        //reset account data
        //override if necessary
        super.resetAuthData()
    }
    
    override class func snTypeString() -> String {
        //kind of login type id for DIAuth system
        return "yourLoginType"
    }
    
    override func snCachedAuthDataIsAvailable() -> Bool {
        //return true or false depending on having cache account data
    }
    
    override func openSession(appID: String, forcedWebView: Bool, vc: UIViewController? = nil) {
        newSocialNetworkService.logInWithPermissions(permissions(), inApp: forcedWebView, fromViewController: nil) { (result, error) -> Void in
            if error != nil {
                //social network auth failed
                DIAuth.sharedInstance.snAuthorizationFailed()
            } else {
                //social network auth succeded
                self.setAuthData(result.userID, newToken: result.tokenString, newUserName: result.userName)
                DIAuth.sharedInstance.snAuthorizationDidComplete()
            }
        }
    }
}
```
And of course don't forget about your new social network in your `DIAuthConnector` implementer

## Requirements

- iOS 7.0+, xCode 7.0+

## Installation

###Manualy

You can integrate DIAuth into your project manually as a submodule. Core files are [here](https://github.com/DmIvanov/DIAuth/tree/master/DIAuth/DIAuth)

DIAuth uses SocialNetwork SDKs and KeyChain wrapper, so you need to add them in your code (manualy or addin them into your podfile)
```ruby
pod 'KeychainAccess'
pod 'VK-ios-sdk'
pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'
```

###CocoaPods

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
