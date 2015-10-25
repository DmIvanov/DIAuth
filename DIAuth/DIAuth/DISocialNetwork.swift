//
//  DISocialNetwork.swift
//  Created by Dmitry Ivanov on 26.09.15.
//

import FBSDKCoreKit


public class DISocialNetwork {
    static var currentNetwork: DISocialNetwork?
    
    private(set) var id: String?
    private(set) var token: String?
    private(set) var userName: String?
    
    
    //MARK: Authorization
    func authorize() {
        if authDataIsAvailable() {
            DIAuth.sharedInstance.snAuthorizationDidComplete()
        } else {
            startSNAuthorisation()
        }
    }
    
    func startSNAuthorisation() {
        if let appID = socialAppID() {
            openSession(appID, forcedWebView: forcedWebView())
        }
    }
    
    func openSession(appID: String, forcedWebView: Bool, vc: UIViewController? = nil) {
        //should be overriden in subclass
    }
    
    
    //MARK: Events from appDelegate
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if DIAuth.sharedInstance.status == DIAuthStatus.SNAuthorising {
            //user came back to app without authorizing
            DIAuth.sharedInstance.snAuthorizationFailed()
        }
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    class func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]!) {
        //  It's necessary to run it even if facebook won't be used.
        //  Facebook cache won't work without it
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    
    //MARK: Auth Data manipulation
    func setAuthData(newId: String? = nil, newToken: String? = nil, newUserName: String? = nil) {
        if newId != nil {
            id = newId
        }
        if newToken != nil {
            token = newToken
        }
        if newUserName != nil {
            userName = newUserName
        }
        if id != nil || token != nil || userName != nil {
            DISocialNetworkCache.writeSNDataToCache(id, token: token, name: userName)
        }
    }
    
    func resetAuthData() {
        id = nil
        token = nil
        userName = nil
        DISocialNetworkCache.resetCacheForSNData()
    }
    
    func readAuthDataFromCache() {
        let (cachedId, cachedToken, cachedName) = DISocialNetworkCache.readSNDataFromCache()
        id = cachedId
        token = cachedToken
        userName = cachedName
    }
    
    
    //MARK: Custom behavior
    func forcedWebView() -> Bool {
        if let forced = DIAuth.sharedInstance.connector?.forcedWebView(self) {
            return forced
        } else {
            return false
        }
    }
    
    func authDataIsAvailable() -> Bool {
        //You can implement more complex checks in child classes overriding this function
        switch DIAuth.sharedInstance.snCacheStrategy {
        case .DICache:
            return diCachedAuthDataIsAvailable()
        case .SNCache:
            return snCachedAuthDataIsAvailable()
        }
        
    }
    
    func diCachedAuthDataIsAvailable() -> Bool {
        if (id != nil) && (token != nil) {
            return true
        } else {
            return false
        }
    }
    
    func snCachedAuthDataIsAvailable() -> Bool {
        //should be overriden in subclass
        return false
    }
    
    public func permissions() -> [String]? {
        return DIAuth.sharedInstance.connector!.permissions(self)
    }
    
    public func socialAppID() -> String? {
        return DIAuth.sharedInstance.connector!.socialAppID(self)
    }
    
    public class func snTypeString() -> String {
        fatalError("Abstract method must be overload in child")
    }
}
