//
//  SceneDelegate.swift
//  CoupDate
//
//  Created by mo on 2024-09-01.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("sceneDidDisconnect")

    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground")


    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("sceneDidEnterBackground")
        UNUserNotificationCenter.current().setBadgeCount(0)


    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            handleIncomingLink(url: incomingURL)
        }
    }
    
    func handleIncomingLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let partnerUserId = queryItems.first(where: { $0.name == "partnerUserId" })?.value else { return }
        
        let sb = UIStoryboard(name: "Main", bundle: .main)
        let pairingVC = sb.instantiateViewController(withIdentifier: "CDPairingViewController") as! CDPairingViewController
        pairingVC.partnerUserId = partnerUserId
        UIApplication.shared.keyWindow?.rootViewController?.present(pairingVC, animated: true)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        // Check if the URL scheme matches your custom scheme
        if url.scheme?.lowercased() == "coupdate" {
            //handleCustomURL(url)
            handleInvitationLink(url)
        }
    }
    
    private func handleCustomURL(_ url: URL) {
        // Use the new queryParameters property to extract parameters
        if let partnerUserId = url.queryParameters?["partnerUserId"] {
            print("Partner User ID: \(partnerUserId)")
            
            // Implement your logic here to handle the partner pairing
            
            let sb = UIStoryboard(name: "Main", bundle: .main)
            let pairingVC = sb.instantiateViewController(withIdentifier: "CDPairingViewController") as! CDPairingViewController
            pairingVC.partnerUserId = partnerUserId
            UIApplication.shared.keyWindow?.rootViewController?.present(pairingVC, animated: true)
            
            
        }
    }
    
    
    func handleInvitationLink(_ url: URL) {
        // Extract the token from the URL
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let token = urlComponents?.queryItems?.first(where: { $0.name == "token" })?.value
        
        // Call Firebase Function to validate the token and pair users
        if let token = token {
            // Call the method on the instance
            
            print("Partner User ID: \(token)")
            
            // Implement your logic here to handle the partner pairing
            
            let sb = UIStoryboard(name: "Main", bundle: .main)
            let pairingVC = sb.instantiateViewController(withIdentifier: "CDPairingViewController") as! CDPairingViewController
            pairingVC.partnerUserId = token
            UIApplication.shared.keyWindow?.rootViewController?.present(pairingVC, animated: true)
        }
        
    }
    
    // Function to convert base64 string to UIImage
    func convertBase64ToImage(base64String: String) -> UIImage? {
        if let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: imageData)
        }
        return nil
    }


    
}

