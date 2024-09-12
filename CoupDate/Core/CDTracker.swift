//
//  CDTracker.swift
//  CoupDate
//
//  Created by mo on 2024-09-10.
//

import Foundation
import BugfenderSDK



struct AnalyticsEventsConstant {
    
    static let AnalyticsEventTripCreated = "User_Created_Trip"
    static let AnalyticsEventTripDeleted = "User_Deleted_Trip"
    static let AnalyticsEventProfileView = "User_Viewed_Profile"
    static let AnalyticsEventMyProfileView = "User_Viewed_MyProfile"
    static let AnalyticsEventAdView = "User_Viewed_Ad"
    static let AnalyticsEventChatStarted = "User_Started_Chat"
    static let AnalyticsEventChatListController = "User_Selected_ChatList_"
    static let AnalyticsEventSearchTripper = "User_Searched_Tripper"
 }
class CDTracker {
    
    class func initializeTrackers() {
        
        // configure Bugfender
        Bugfender.activateLogger("in1hJXdgkCxcPYwslHLxJTjhwAUjrgqC")
        Bugfender.enableCrashReporting()
        Bugfender.enableUIEventLogging()
        // configure Firebase
        CDTracker.configuration()
    }
    
    
    class func forceSendLogs() {
        Bugfender.forceSendOnce()
    }
    
    class func configuration() {
        if let name = CDDataProvider.shared.name {
            Bugfender.setDeviceString(name, forKey: "name")
        }
    }
    
    class func trackIssue(title:String,text:String) {
        configuration()
        Bugfender.sendIssueReturningUrl(withTitle: title, text: text)
    }
    
    class func trackEvent(eventName:String,params:[String:Any] = [:]) {
        configuration()
        bfprint("Title: \(eventName) -- Text: \(params)")
    }
}
