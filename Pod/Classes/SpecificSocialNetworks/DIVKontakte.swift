//
//  DIVKontakte.swift
//  Created by Dmitry Ivanov on 11.10.15.
//

import VK_ios_sdk


class DIVKontakte: DISocialNetwork {
    
    //MARK: Properties
    lazy var sdkDelegate: VKDelegate = VKDelegate(sn: self)
    
    
    //MARK: Lyfecycle
    override init() {
        super.init()
        VKSdk.initializeWithDelegate(sdkDelegate, andAppId: socialAppID())
    }
    
    
    //MARK: Events from appDelegate
    override func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }
    
    override func applicationDidBecomeActive(application: UIApplication) {
    }
    
    
    //MARK:
    override func openSession(appID: String, forcedWebView: Bool, vc: UIViewController? = nil) {
        VKSdk.authorize(permissions(), revokeAccess: true, forceOAuth: false, inApp: forcedWebView)
    }
    
    override func snCachedAuthDataIsAvailable() -> Bool {
        let sdkIsReady = VKSdk.wakeUpSession()
        if sdkIsReady {
            let id = VKSdk.getAccessToken().userId
            let token = VKSdk.getAccessToken().accessToken
            setAuthData(id, newToken: token)
            sendProfileRequest()
        }
        return sdkIsReady
    }
    
    override func resetAuthData() {
        VKSdk.forceLogout()
        super.resetAuthData()
    }
    
    override class func snTypeString() -> String {
        return "vk"
    }
    
    private func sendProfileRequest() {
        if id == nil {
            return
        }
        let request = VKApi.users().get([VK_API_USER_ID : id!])
        request.executeWithResultBlock({ (response) -> Void in
           let name = self.userNameFromResponse(response)
            self.setAuthData(newUserName: name)
            }) { (error) -> Void in
                if error.code == Int(VK_API_ERROR) {
                    print("VK Error: \(error)")
                } else {
                    //error.vkError.request.repeat()
                    print("VK not API Error: \(error)")
                }
        }
    }
    
    private func userNameFromResponse(response: VKResponse) -> String? {
        var vkProfile: [String : AnyObject]?
        if let jsonArray = response.json as? [AnyObject] {
            if jsonArray.count != 0 {
                vkProfile = jsonArray[0] as? [String : AnyObject]
            }
        } else {
            vkProfile = response.json as? [String : AnyObject]
        }
        if let profile = vkProfile {
            let firstName = profile["first_name"]
            let lastName = profile["last_name"]
            return "\(firstName) \(lastName)"
        }
        return nil
    }
}


class VKDelegate: NSObject, VKSdkDelegate {
    
    //MARK: Properties
    weak var vkSN: DIVKontakte?
    
    
    //MARK: Lyfecycle
    init(sn: DIVKontakte) {
        vkSN = sn
    }
    
    
    //MARK: VKSdkDelegate methods
    @objc func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
    }
    
    @objc func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        DIAuth.sharedInstance.snAuthorizationFailed()
    }
    
    @objc func vkSdkUserDeniedAccess(authorizationError: VKError!) {
        DIAuth.sharedInstance.snAuthorizationFailed()
    }
    
    @objc func vkSdkShouldPresentViewController(controller: UIViewController!) {
    }
    
    @objc func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
        if vkSN == nil {
            assert(vkSN != nil, "No vkSN property in VKDelegate")
            return
        }
        let token = newToken.accessToken
        let userId = newToken.userId
        vkSN!.setAuthData(userId, newToken: token)
        vkSN!.sendProfileRequest()
        DIAuth.sharedInstance.snAuthorizationDidComplete()
    }

}


