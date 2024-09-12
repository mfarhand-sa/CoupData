//
//  UserManager.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import Foundation
import FirebaseAuth

class UserManager {
    static let shared = UserManager()

    public var currentUserID: String?
    public var partnerUserID: String?  // Replace with your girlfriend's actual userID // myUserID123


    private init() {
        // Initialize currentUserID with Firebase Auth's current user ID, if available
        if let user = Auth.auth().currentUser {
            self.currentUserID = user.uid
        } else {
            self.currentUserID = nil // User not signed in
        }
    }

    // Get the current user ID
    var userID: String? {
        return currentUserID
    }

    // Refresh the current user ID (in case of sign-in/out)
    func refreshUserID() {
        if let user = Auth.auth().currentUser {
            self.currentUserID = user.uid
            print("Current User ID refreshed: \(currentUserID ?? "nil")")
        } else {
            self.currentUserID = nil
            print("User not signed in")
        }
    }
    
    // Observe Authentication State Changes
    func observeAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.currentUserID = user.uid
                print("User signed in: \(user.uid)")
            } else {
                self?.currentUserID = nil
                print("User signed out")
            }
        }
    }

    // Optional: Switch to another user's ID if needed
    // This function is more for testing/mimicking behavior if needed.
    func switchUserID(to newUserID: String?) {
        self.currentUserID = newUserID
        print("Switched to User ID: \(currentUserID ?? "nil")")
    }
}

