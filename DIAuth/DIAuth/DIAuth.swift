//
//  DIAuth.swift
//  Created by Dmitry Ivanov on 26.09.15.
//

import Foundation

public enum DIAuthStatus: String {
    
    /**
    Auth system inited.
    The next status will be automatically set to
    .WaitingForUser - if there is no Social Network Manager in cache
    .SocialNetworkAuthorizing - if there's some cached Social Network Manager */
    case Init = "Init"
    
    /**
    System has no Social Network Manager and waiting for user login */
    case WaitingForUser = "WaitingForUser"
    
    /**
    Social Network Manager started authorization
    The next status will be automatically set to
    .SNAuthorised - if social network authorization will succed
    .SNFailed - if social network authorization will fail or will be canceled by user */
    case SNAuthorising = "SNAuthorising"
    
    /**
    Social Network Manager finished authorization
    */
    case SNAuthorised = "SNAuthorised"
    
    /**
    Social network authorization failed
    The next status will be automatically set to
    .WaitingForUser
    */
    case SNFailed = "SNFailed"
    
    /**
    Server authorization started
    */
    case Authorising = "Authorising"
    
    /**
    Server authorization finished
    */
    case Authorised = "Authorised"
    
    /**
    Intermediate state, when sn-authorization succeded, 
    but server authorization
    */
    case Revoke = "Revoke"
    
    /**
    Server authorization failed
    */
    case Failed = "Failed"
}

public enum DISNCacheStrategy {
    case SNCache
    case DICache
}

public let kDIAuthDidStartWithCachedSNNotification = "kDIAuthDidStartWithCachedSNNotification"
public let kDIAuthStatusDidChangeNotification = "kDIAuthStatusDidChangeNotification"

public let kDIAuthDidStartWithCachedSNKey = "kDIAuthDidStartWithCachedSNKey"
public let kDIAuthStatusDidChangeOldStatusKey = "kDIAuthStatusDidChangeOldStatusKey"
public let kDIAuthStatusDidChangeNewStatusKey = "kDIAuthStatusDidChangeNewStatusKey"


public typealias DIServerAuthCompletionBlock = (success: Bool) -> Void


public protocol DIAuthConnector: AnyObject {
    
    /**
    Connector should return initialized Sosial Network.
    It should be a child from DISocialNetwork: DIFacebook, DIVKontakte or the custom Social Network
    @params: type - the string type that Social Network returns in snTypeString() -> String
    */
    func socialNetworkForType(type: String?) -> DISocialNetwork?
    
    /**
    Permissions for authorising in Social Network
    */
    func permissions(sn: DISocialNetwork) -> [String]?
    
    /**
    ID of your app in social network.
    */
    func socialAppID(sn: DISocialNetwork) -> String?
    
    /**
    Is in-app webView is necessary for authorization
    Returning value:
    - 'true' if you need in-app authorization.
    - 'false' if you want native social network authorization (social network will decide if it should be it's own app, browser or web view)
    */
    func forcedWebView(sn: DISocialNetwork) -> Bool
    
    /**
    Method for starting your own server authorization, called when social network authorization is completed.
    */
    func startServerAuthorization(completion: DIServerAuthCompletionBlock)
}


public class DIAuth {
    
    //MARK: Properties
    public static let sharedInstance = DIAuth()
    
    public var connector: DIAuthConnector?
    public var snCacheStrategy = DISNCacheStrategy.SNCache
    private(set) public var status = DIAuthStatus.Init
    
    
    //MARK: Lyfecycle
    init() {
        adjustNotification()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //MARK: Outside interface
    public func start(socialNetwork: DISocialNetwork?, newConnector:DIAuthConnector) {
        var sn = socialNetwork
        self.connector = newConnector
        if sn != nil {
            DISocialNetworkCache.writeSNTypeToCache(sn!.dynamicType.snTypeString())
        } else {
            let snType = DISocialNetworkCache.readSNTypeFromCache()
            sn = self.connector!.socialNetworkForType(snType)
            if sn != nil {
                sn!.readAuthDataFromCache()
                NSNotificationCenter.defaultCenter().postNotificationName(kDIAuthDidStartWithCachedSNNotification, object: self, userInfo: [kDIAuthDidStartWithCachedSNKey : sn!])
            }
        }
        
        if sn != nil {
            self.setNewState(DIAuthStatus.SNAuthorising, sn: sn!)
        } else {
            self.setNewState(DIAuthStatus.WaitingForUser)
        }
    }
    
    public func logOut() {
        reset()
        setNewState(.WaitingForUser)
    }
    
    public func currentSocialNetwork() -> DISocialNetwork? {
        return DISocialNetwork.currentNetwork
    }
    
    public func resetServerAuth() {
        setNewState(.Revoke)
    }
    
    public func restoreServerAuth() {
        startServerAuth()
    }

    
    
    //MARK: Events from appDelegate
    public func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]!) {
        DISocialNetwork.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let sn = DISocialNetwork.currentNetwork {
            return sn.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return true
        }
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        if let sn = DISocialNetwork.currentNetwork {
            sn.applicationDidBecomeActive(application)
        }
    }
    
    
    //MARK: Inside interface
    func snAuthorizationDidComplete() {
        setNewState(.SNAuthorised)
    }
    
    func snAuthorizationFailed() {
        setNewState(.SNFailed)
    }
    
    func startServerAuth() {
        setNewState(.Authorising)
        if let con = connector {
            con.startServerAuthorization({ (success) -> Void in
                let newStatus = success ? DIAuthStatus.Authorised : DIAuthStatus.Failed
                self.setNewState(newStatus)
            })
        }
    }
    
    
    //MARK: Private methods
    private func setNewState(newStatus: DIAuthStatus, sn: DISocialNetwork? = DISocialNetwork.currentNetwork) {
        if status == newStatus && sn.dynamicType == DISocialNetwork.currentNetwork.dynamicType {
            //no state changing
            return
        }
        let oldStatus = status
        status = newStatus
        DISocialNetwork.currentNetwork = sn
        print("Auth status set to \(newStatus)")
        let userInfo = [kDIAuthStatusDidChangeOldStatusKey : oldStatus.rawValue,
            kDIAuthStatusDidChangeNewStatusKey : newStatus.rawValue]
        NSNotificationCenter.defaultCenter().postNotificationName(kDIAuthStatusDidChangeNotification, object: self, userInfo: userInfo)
    }
    
    private func adjustNotification() {
        let notCenter = NSNotificationCenter.defaultCenter()
        notCenter.addObserver(self, selector: "authStatusDidChange:", name: kDIAuthStatusDidChangeNotification, object: self)
    }
    
    private func reset() {
        DISocialNetwork.currentNetwork?.resetAuthData()
        DISocialNetwork.currentNetwork = nil
        DISocialNetworkCache.resetCacheForSNType()
    }
    
    
    //MARK: Notification processing
    @objc private func authStatusDidChange(notification: NSNotification) {
        switch (status) {
        case .SNAuthorising:
            DISocialNetwork.currentNetwork?.authorize()
        case .SNFailed:
            reset()
            setNewState(.WaitingForUser)
        case .SNAuthorised:
            startServerAuth()
        default:
            return
        }
    }
}


