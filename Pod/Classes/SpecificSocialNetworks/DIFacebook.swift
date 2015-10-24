//
//  DIFacebook.swift
//  Created by Dmitry Ivanov on 26.09.15.
//

import FBSDKCoreKit
import FBSDKLoginKit


class DIFacebook: DISocialNetwork {
    
    //MARK: Properties
    var fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
    
    
    //MARK: Events from appDelegate
    override func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    override func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    
    //MARK: 
    override func resetAuthData() {
        fbLoginManager.logOut()
        super.resetAuthData()
    }
    
    override class func snTypeString() -> String {
        return "fb"
    }
    
    override func snCachedAuthDataIsAvailable() -> Bool {
        return fillDataFromFBToken()
    }
    
    override func openSession(appID: String, forcedWebView: Bool, vc: UIViewController? = nil) {
        fbLoginManager.loginBehavior = forcedWebView ? FBSDKLoginBehavior.Web : FBSDKLoginBehavior.Native
        FBSDKSettings.setAppID(socialAppID())
        fbLoginManager.logInWithReadPermissions(permissions(), fromViewController: nil) { (result, error) -> Void in
            if error != nil {
                DIAuth.sharedInstance.snAuthorizationFailed()
                print("Auth error: \(error)")
            } else if result.isCancelled {
                DIAuth.sharedInstance.snAuthorizationFailed()
                print("Auth canceled")
            } else {
                self.fbDidFinish(result)
            }
        }
    }
    
    private func fbDidFinish(result: FBSDKLoginManagerLoginResult) {
        guard fillDataFromFBToken() else {
            return
        }
        DIAuth.sharedInstance.snAuthorizationDidComplete()
        FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
            //let id = result["id"] as? String
            let name = result["name"] as? String
            self.setAuthData(newUserName: name)
        })
    }
    
    private func fillDataFromFBToken() -> Bool {
        if let fbToken = FBSDKAccessToken.currentAccessToken() {
            setAuthData(fbToken.userID, newToken: fbToken.tokenString, newUserName: nil)
            return true
        } else {
            return false
        }
    }
}
