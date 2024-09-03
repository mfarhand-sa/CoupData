//
//  UserManager.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import Foundation


import Foundation

class UserManager {
    static let shared = UserManager()
    
    // Hardcoded user IDs for testing
    let myUserID = "myUserID123"  // Replace with your actual userID // partnerUserID456
    let partnerUserID = "partnerUserID456"  // Replace with your girlfriend's actual userID // myUserID123
    
    private var currentUserID: String
    
    private init() {
        // Start with your user ID by default
        self.currentUserID = myUserID
    }
    
    // Get the current user ID
    var userID: String {
        return currentUserID
    }
    
    // Switch to your user ID
    func switchToMyUserID() {
        currentUserID = myUserID
        print("Switched to My User ID: \(currentUserID)")
    }
    
    // Switch to your girlfriend's user ID
    func switchToGfUserID() {
        currentUserID = partnerUserID
        print("Switched to Partner's User ID: \(currentUserID)")
    }
}
