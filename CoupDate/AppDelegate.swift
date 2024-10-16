//
//  AppDelegate.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn
import Lottie


@main
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Haptic.doSomethinStupid(status: false)
        LottieConfiguration.shared.renderingEngine = .automatic
        CDTracker.initializeTrackers()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        WatchSessionManager.shared.startSession()
        
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self // Set the notification delegate        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        print(tokenString)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "No token")")
        
        // Ensure the token is available
        guard let token = fcmToken else { return }
        
        guard let signedIn = UserDefaults.standard.value(forKey: "loggedIn") else { return }
        
        // Check if the user is signed in
        if let user = Auth.auth().currentUser {
            // User is signed in, send the token to the server
            sendTokenToServer(token: token)
            
        } else {
            // Optionally: Listen for user sign-in if needed
           // NotificationCenter.default.addObserver(self, selector: #selector(handleUserSignedIn), name: .AuthStateDidChange, object: nil)
        }
    }
    
    
    @objc func handleUserSignedIn() {
        guard let token = Messaging.messaging().fcmToken else { return }
        if let userId = Auth.auth().currentUser?.uid {
            sendTokenToServer(token: token)
        }
    }
    
    
    
    func sendTokenToServer(token: String) {
        
        let userId = UserManager.shared.currentUserID // Replace with the actual user ID
        guard let userId = userId else {return}
        let db = Firestore.firestore()
        
        // Use a subcollection for tokens under each user
        db.collection("users").document(userId).collection("deviceTokens").document(token).setData([
            "token": token,
            "timestamp": Timestamp()
        ]) { error in
            if let error = error {
                print("Error saving token to Firestore: \(error)")
            } else {
                print("FCM Token saved to Firestore: \(token)")
            }
        }
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool
        
        if url.scheme == "coupdate" {
            
            handleCustomURL(url)
            return true
        }
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        // If not handled by this app, return false.
        return false
        
    }
    
    private func handleCustomURL(_ url: URL) {
        // Extract any parameters from the URL if needed
        if let partnerUserId = url.queryParameters?["partnerUserId"] {
            print("Partner User ID: \(partnerUserId)")
            // Implement your logic here to handle the partner pairing
            
            let sb = UIStoryboard(name: "Main", bundle: .main)
            let pairingVC = sb.instantiateViewController(withIdentifier: "CDPairingViewController") as! CDPairingViewController
            pairingVC.partnerUserId = partnerUserId
            UIApplication.shared.keyWindow?.rootViewController?.present(pairingVC, animated: true)
            
        }
    }
    
    
    func handleIncomingLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let partnerUserId = queryItems.first(where: { $0.name == "partnerUserId" })?.value else { return }
        
        // Call your function to save the partner userId to Firebase
        // FirebaseManager.shared.savePartnerUserId(partnerUserId)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Handle background notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Received notification with userInfo: \(userInfo)")
        
        // Update UI or perform an action when a notification is tapped
        handleNotification(userInfo: userInfo)
        
        completionHandler()
    }
    
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received notification with userInfo: \(userInfo)")
        
        // Show notification while in the foreground
        completionHandler([.alert, .badge, .sound])
        
        // Update UI or perform an action
        handleNotification(userInfo: userInfo)
    }
    
    // Handle the notification and update the UI
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        // Log the entire userInfo dictionary to see its content
        print("Received push notification with userInfo: \(userInfo)")
        
        // Extract specific data if available
        
        
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let notificationTitle = alert["title"] as? String,
           let notificationBody = alert["body"] as? String {
            print("Notification Title: \(notificationTitle)")
            print("Notification Body: \(notificationBody)")
            
            
            print("Notification Title: \(notificationTitle)")
            print("Notification Body: \(notificationBody)")
            
            if let rootVCView = UIApplication.shared.keyWindow?.rootViewController?.view {
                
                if notificationTitle == "Partner Joined" {
                    CustomAlerts.displayNotification(title: "", message:"👩‍❤️‍👨 Your partner has been joined 👩‍❤️‍👨", view: rootVCView)
                    
                    NotificationCenter.default.post(name: NSNotification.Name("Partner_Joined"), object: nil)
                    
                } else {
                    CustomAlerts.displayNotification(title: notificationTitle, message: notificationBody, view:rootVCView ,fromBottom: true)
                }
            }
        }
        else {
            print("Failed to extract notification title and body")
        }
    }
    
}

