//
//  AppDelegate.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import UIKit
import Firebase
import FirebaseMessaging


@main
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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
        let userId = UserManager.shared.myUserID // Replace with the actual user ID
           let db = Firestore.firestore()
           db.collection("deviceTokens").document(userId).setData([
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
