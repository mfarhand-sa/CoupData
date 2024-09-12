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


@main
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Haptic.doSomethinStupid(status: false)
        CDTracker.initializeTrackers()
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named: "TabbarNormal")!]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.accent]
            appearance.stackedLayoutAppearance.normal.iconColor =  UIColor(named: "TabbarNormal")!
            appearance.stackedLayoutAppearance.selected.iconColor =  UIColor.accent
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Permission granted: \(granted)")
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        print(tokenString)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "No token")")
        // Send the token to your server or handle as needed
        guard let token = fcmToken else { return }
        sendTokenToServer(token: token)
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Handle the notification content
        print("Received notification with userInfo: \(userInfo)")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Handle the notification content while the app is in the foreground
        print("Received notification with userInfo: \(userInfo)")
        completionHandler([.alert, .badge, .sound])
    }
}
