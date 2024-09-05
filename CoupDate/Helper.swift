//
//  Helper.swift
//  CoupDate
//
//  Created by mo on 2024-09-04.
//

import Foundation
import SwiftMessages
import CoreHaptics
import NotificationBannerSwift


class CustomAlerts{
    enum notificationType:Int {
    case error = 0
    case warning = 1
    case message = 2
    }
    static func displayError(message:String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            let viewController = UIApplication.shared.windows.first!.rootViewController
            if let childVC = viewController?.presentedViewController {
                childVC.present(alert, animated: true, completion: nil)

            } else {
                viewController?.present(alert, animated: true, completion: nil)

            }
        }
    }
    
    static func display(title:String, message:String,action:[UIAlertAction]){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            for actions in action {
                alert.addAction(actions)
            }
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            viewController?.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @MainActor static func displayMessage(title:String, message:String,view:UIView) {
        SwiftMessages.defaultConfig.presentationStyle = .top
        let customview = MessageView.viewFromNib(layout: .messageView)
        customview.titleLabel?.text = title
        customview.bodyLabel?.text = message
        customview.iconLabel?.text = ""
        customview.button?.isHidden = true
        SwiftMessages.show(view: customview)
    }
    
    
    @MainActor static func displayNotification(title:String, message:String,view:UIView,type:notificationType = .message, fromBottom:Bool = true, style: BannerStyle = .info) {
        var config = SwiftMessages.Config()
        if(!fromBottom) {
            config.presentationStyle = .top
        } else {
            config.presentationStyle = .bottom

        }
        config.duration = .seconds(seconds: 4)
        let customview = MessageView.viewFromNib(layout: .messageView)
        customview.titleLabel?.text = title
        customview.titleLabel?.font = UIFont(name:"Poppins-Regular", size: customview.titleLabel?.font.pointSize ?? 15)
        customview.bodyLabel?.text = message
        customview.bodyLabel?.font = UIFont(name:"Poppins-Regular", size: customview.bodyLabel?.font.pointSize ?? 15)
        customview.iconLabel?.text = ""
        customview.button?.isHidden = true
        SwiftMessages.show(config: config, view: customview)
        switch type {
        case .message :
            Haptic.play()
        case .error :
            Haptic.vibrating()
        case .warning:
            Haptic.vibrating()

        }
    }
    
}

class Haptic {
    
    
    static func play() {
        
        var supportsHaptics: Bool = false
        // Check if the device supports haptics.
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        if supportsHaptics == false {
            return
        }
        let feedBack = UINotificationFeedbackGenerator()
        feedBack.prepare()
        feedBack.notificationOccurred(.success)
    }
    
    static func vibrating() {
        var supportsHaptics: Bool = false
        // Check if the device supports haptics.
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        if supportsHaptics == false {
            return
        }
        let feedBack = UIImpactFeedbackGenerator()
        feedBack.prepare()
        feedBack.impactOccurred(intensity: 1.0)
    }
    
    static func intenesVibrating() {
        var supportsHaptics: Bool = false
        // Check if the device supports haptics.
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        if supportsHaptics == false {
            return
        }
        let feedBack = UIImpactFeedbackGenerator(style: .heavy)
        feedBack.prepare()
        feedBack.impactOccurred(intensity: 1.0)
    }
    
    static func doSomethinStupid(status: Bool) {
        var supportsHaptics: Bool = false
        // Check if the device supports haptics.
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        if supportsHaptics == false {
            return
        }
        
        let feedBack = UIImpactFeedbackGenerator()
        feedBack.prepare()
        feedBack.impactOccurred(intensity: 1.0)
    }
    
}
