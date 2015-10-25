//
//  DISocialNetworkCache.swift
//  Created by Dmitry Ivanov on 26.09.15.
//

import KeychainAccess

let kDISNUserIdKey      = "kDISNUserId"
let kDISNTokenKey       = "kDISNToken"
let kDISNUserNameKey    = "kDISNUserName"

let kDISNTypeKey        = "defaultsSNTypeKey"


class DISocialNetworkCache {
    
    //MARK: Social Network Data affairs
    class func writeSNDataToCache(id: String?, token: String?, name: String?) {
        let keychain = appKeychain()
        if id != nil {
            keychain[kDISNUserIdKey] = id
        }
        if token != nil {
            keychain[kDISNTokenKey] = token
        }
        if name != nil {
            keychain[kDISNUserNameKey] = name
        }
    }
    
    class func readSNDataFromCache() -> (id: String?, token: String?, name: String?) {
        let keychain = appKeychain()
        let id = keychain[kDISNUserIdKey]
        let token = keychain[kDISNTokenKey]
        let userName = keychain[kDISNUserNameKey]
        return (id, token, userName)
    }
    
    class func resetCacheForSNData() {
        let keychain = appKeychain()
        keychain[kDISNUserIdKey] = nil
        keychain[kDISNTokenKey] = nil
        keychain[kDISNUserNameKey] = nil
    }
    
    
    //MARK: Social Network Type affairs
    class func writeSNTypeToCache(type: String) {
        NSUserDefaults.standardUserDefaults().setObject(type, forKey: kDISNTypeKey)
    }
    
    class func readSNTypeFromCache() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey(kDISNTypeKey) as? String
    }
    
    class func resetCacheForSNType() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kDISNTypeKey)
    }
    
    
    //MARK: Setters & getters
    private class func appKeychain() -> Keychain {
        return Keychain(service: NSBundle.mainBundle().bundleIdentifier!)
    }
}
