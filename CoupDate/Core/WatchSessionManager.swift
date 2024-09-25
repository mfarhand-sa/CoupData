//
//  WatchSessionManager.swift
//  CoupDate
//
//  Created by mo on 2024-09-24.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchSessionManager()
    
    private override init() {
        super.init()
    }
    
    func startSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("Session activated with state: \(activationState.rawValue)")
    }
    
    // This method is available only on iOS, not on watchOS.
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Only used on iOS
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Only used on iOS
        session.activate()  // Reactivate the session if necessary.
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("Watch state changed")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Session reachability changed")
    }
#endif
    
    // Handle receiving messages (used on both iOS and watchOS)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: (([String : Any]) -> Void)? = nil) {
        print("Message received: \(message)")
        
        
#if os(iOS)
        
        if let category = CDMessageHelper.category(for: message["message"] as! String) {
            // Call your method to display the random message
            
            if let randomMessage = CDMessageHelper.sendRandomMessageBasedOnGender(category: category, userGender: CDDataProvider.shared.gender ?? "") {
                print(randomMessage) // For now, we're just printing the message
                
                FirebaseManager.shared.sendMessageToPartner(partnerUid: UserManager.shared.partnerUserID!, message:randomMessage , messageType: category.rawValue)
                replyHandler?(["Status":"Message sent 🎉"])
                
            } else {
                print("No messages available for this category.")
            }
            
            
        } else {
            print("oops can't create the category")
        }
#endif
        
        
    }
    
    
    
}
