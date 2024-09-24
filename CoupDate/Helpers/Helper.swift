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
import CoreTelephony



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


extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        var params = [String: String]()
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}


extension String {
    
    func capitalizeFirstLetters() -> String {
        // Split the string into components separated by spaces
        return self.split(separator: " ").map { word in
            // Capitalize the first letter of each word and lowercase the rest
            word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }.joined(separator: " ")
    }
    
    func toDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from:self)!
    }
    
    func prettyDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: self) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "MMM dd"
            newDateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Set output time zone to UTC
            return newDateFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
    
    func myTripPretty()-> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: self) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "MMM dd"
            newDateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Set output time zone to UTC
            return newDateFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
        
    }
    
    
    //    func capitalizingFirstLetter() -> String {
    //        return prefix(1).capitalized + dropFirst()
    //    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizeFirstLetters()
    }
    
    var urlEncoded: String? {
        //let escapedString = originalString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        // let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    func isValidPhoneNumber() -> Bool {
        
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    func removingLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return self
        }
        return String(self[index...])
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    func getTheSecondWord() -> String {
        if let range = self.range(of: " ") {
            return  self[range.upperBound...].trimmingCharacters(in: .whitespaces)
        }
        return ""
    }
    func getTheFirstWord() -> String {
        
        if let first = self.components(separatedBy: " ").first {
            // Do something with the first component.
            return first
        }
        return self
    }
    
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    
    
}


@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}


@IBDesignable
public class RoundedView: UIView {
    
    @IBInspectable public var topLeft: Bool = false      { didSet { updateCorners() } }
    @IBInspectable public var topRight: Bool = false     { didSet { updateCorners() } }
    @IBInspectable public var bottomLeft: Bool = false   { didSet { updateCorners() } }
    @IBInspectable public var bottomRight: Bool = false  { didSet { updateCorners() } }
    @IBInspectable public var cornerRadius: CGFloat = 0  { didSet { updateCorners() } }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
            updateCorners()
        }
        get {
            return layer.borderWidth
        }
    }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        updateCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateCorners()
    }
}

private extension RoundedView {
    func updateCorners() {
        var corners = CACornerMask()
        
        if topLeft     { corners.formUnion(.layerMinXMinYCorner) }
        if topRight    { corners.formUnion(.layerMaxXMinYCorner) }
        if bottomLeft  { corners.formUnion(.layerMinXMaxYCorner) }
        if bottomRight { corners.formUnion(.layerMaxXMaxYCorner) }
        
        layer.maskedCorners = corners
        layer.cornerRadius = cornerRadius
    }
}




@IBDesignable
public class RoundedImageView: UIImageView {
    
    @IBInspectable public var topLeft: Bool = false { didSet { updateCorners() } }
    @IBInspectable public var topRight: Bool = false { didSet { updateCorners() } }
    @IBInspectable public var bottomLeft: Bool = false { didSet { updateCorners() } }
    @IBInspectable public var bottomRight: Bool = false { didSet { updateCorners() } }
    @IBInspectable public var cornerRadius: CGFloat = 0 { didSet { updateCorners() } }
    
    private var maskLayer: CAShapeLayer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        updateCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateCorners()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
    }
    
    private func updateCorners() {
        let path = UIBezierPath()
        
        if topLeft {
            path.move(to: CGPoint(x: 0, y: cornerRadius))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
        }
        
        if topRight {
            path.addLine(to: CGPoint(x: bounds.width - cornerRadius, y: 0))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: 0, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
        }
        
        if bottomRight {
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - cornerRadius))
            path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: bounds.height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi * 0.5, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        }
        
        if bottomLeft {
            path.addLine(to: CGPoint(x: cornerRadius, y: bounds.height))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: bounds.height - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi * 0.5, endAngle: CGFloat.pi, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: 0, y: bounds.height))
        }
        
        path.close()
        
        if maskLayer == nil {
            maskLayer = CAShapeLayer()
            layer.mask = maskLayer
        }
        
        maskLayer?.path = path.cgPath
    }
}



//    func updateRootViewController(to viewController: UIViewController) {
//        // Ensure we are running on the main thread
//        guard Thread.isMainThread else {
//            DispatchQueue.main.async {
//                self.updateRootViewController(to: viewController)
//            }
//            return
//        }
//
//        if let windowScene = UIApplication.shared.connectedScenes
//            .filter({ $0.activationState == .foregroundActive })
//            .compactMap({ $0 as? UIWindowScene })
//            .first,
//           let window = windowScene.windows.first {
//            window.rootViewController = viewController
//            window.makeKeyAndVisible()
//        } else {
//            print("No active window scene found.")
//        }
//    }



extension UIViewController {
    
    func updateRootViewController(to viewController: UIViewController) {
        // Ensure we are running on the main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.updateRootViewController(to: viewController)
            }
            return
        }
        
        // Get the active window scene
        if let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first,
           let window = windowScene.windows.first {
            
            guard let currentVC = window.rootViewController else {
                window.rootViewController = viewController
                window.makeKeyAndVisible()
                return
            }
            
            // Set the new rootViewController of the window.
            // Calling "UIView.transition" below will animate the swap.
            window.rootViewController = viewController
            
            // A mask of options indicating how you want to perform the animations.
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            
            // The duration of the transition animation, measured in seconds.
            let duration: TimeInterval = 0.4
            
            // Creates a transition animation.
            // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
                                { completed in
                // maybe do something on completion here
            })
        } else {
            print("No active window scene found. Retrying in 0.5 seconds.")
            // Retry after a small delay if no active window scene
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateRootViewController(to: viewController)
            }
        }
    }
    
}


extension UIColor {
    static var accent: UIColor {
        return UIColor(named: "CDAccent") ?? UIColor(red: 255.0/255.0, green: 175.0/255.0, blue: 127.0/255.0, alpha: 1.0) // Fallback color
    }
    
    static var CDBackground: UIColor {
        return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0) // #F2F2F2
    }
    
    static var CDText: UIColor {
        return UIColor(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 1.0) // #1A1A1A
    }
}


class CDMessageHelper {
    
    enum CDMessageCategory: String {
        case love
        case supportive
        case intimacy
        case dirty
    }
    
    enum Gender: String {
        case man
        case woman
        case general
    }
    
    // Mapping method to get the category from a string
    static func category(for title: String) -> CDMessageCategory? {
        switch title {
        case "Dirty 🔥":
            return .dirty
        case "Love 💌":
            return .love
        case "Supportive 💪":
            return .supportive
        case "Intimacy ❤️‍🔥":
            return .intimacy
        default:
            return nil
        }
    }
    
    
    //    static let messages = [
    //        "love": [
    //            "You're my safe place.",
    //            "Your smile makes my day.",
    //            "You're my greatest adventure.",
    //            "You complete me in every way.",
    //            "With you, everything feels right.",
    //            "I can't imagine life without you.",
    //            "My heart beats just for you.",
    //            "You're my sunshine on a cloudy day.",
    //            "You light up my life.",
    //            "Every day with you is a blessing.",
    //            "You're my favorite hello and hardest goodbye.",
    //            "I love you more than words can say.",
    //            "You make every moment special.",
    //            "You're my perfect match.",
    //            "I'm so lucky to have you.",
    //            "You're the reason I believe in love.",
    //            "Being with you is my favorite thing.",
    //            "My heart belongs to you, always.",
    //            "I adore everything about you.",
    //            "You make my world a better place.",
    //            "You're the best part of my life.",
    //            "You are my forever.",
    //            "My love for you grows every day.",
    //            "You are my person.",
    //            "You have my heart.",
    //            "I'm so grateful for you.",
    //            "You're my one and only.",
    //            "You're my everything.",
    //            "I love the way you make me feel.",
    //            "You're the one I want to spend my life with.",
    //            "You make my heart race.",
    //            "I'm happiest when I'm with you.",
    //            "I love being by your side.",
    //            "You're my home.",
    //            "You make me feel so loved.",
    //            "You're my dream come true.",
    //            "I love every little thing about you.",
    //            "You are my happiness.",
    //            "You make my heart smile.",
    //            "You're the love of my life.",
    //            "I can't stop thinking about you.",
    //            "I love you more every day.",
    //            "You make everything better.",
    //            "You mean the world to me.",
    //            "You're my forever and always.",
    //            "You're my favorite person to talk to.",
    //            "You're the best thing that ever happened to me.",
    //            "You make me believe in love.",
    //            "You and me, always.",
    //            "I'm so lucky to be with you.",
    //            "You're my greatest treasure.",
    //            "You have my heart completely.",
    //            "You're my endless love.",
    //            "You bring joy to my life.",
    //            "I love you to the moon and back.",
    //            "You're my one true love.",
    //            "You're my better half.",
    //            "I can't wait to spend forever with you.",
    //            "You're my heart's desire.",
    //            "You make my soul happy.",
    //            "You fill my life with love.",
    //            "You are my everything.",
    //            "You complete my life.",
    //            "You are my sweetest dream.",
    //            "I love being with you.",
    //            "You're my heart's song.",
    //            "You make my life complete.",
    //            "You're my love story.",
    //            "You make my heart skip a beat.",
    //            "You are my happy place.",
    //            "You're my endless love.",
    //            "You are the reason I smile.",
    //            "You make every day better.",
    //            "You're my heart's keeper.",
    //            "You are my heart.",
    //            "You make me feel alive.",
    //            "You are my favorite person.",
    //            "You make my heart sing.",
    //            "You're my everything and more.",
    //            "You are my love, my life.",
    //            "You are my best friend and my love.",
    //            "You're the love of my life.",
    //            "You are my reason to be happy.",
    //            "You're my world.",
    //            "You are my one and only love.",
    //            "You make my heart soar.",
    //            "You make my life beautiful.",
    //            "You are my greatest love.",
    //            "You are my forever love.",
    //            "You're the reason I smile every day.",
    //            "You make my world go round.",
    //            "You are my perfect love.",
    //            "You are my true love.",
    //            "You make me believe in fairy tales.",
    //            "You are my heart and soul.",
    //            "You are my one true love.",
    //            "You make my dreams come true.",
    //            "You are my happy ending.",
    //            "You are my sweet escape.",
    //            "You are my everything, always.",
    //            "You are my love and my light.",
    //            "You are my heart's one desire.",
    //            "You are my one and only dream."
    //        ],
    //        "supportive": [
    //            "You've got this!",
    //            "I'm so proud of you.",
    //            "You are stronger than you think.",
    //            "I'm here for you, always.",
    //            "Keep pushing forward.",
    //            "You inspire me every day.",
    //            "You're capable of amazing things.",
    //            "I believe in you.",
    //            "You're doing an amazing job.",
    //            "I'm right by your side.",
    //            "You make me proud.",
    //            "You're a fighter.",
    //            "You can do anything you set your mind to.",
    //            "I'm here to support you.",
    //            "You're not alone in this.",
    //            "You have my full support.",
    //            "I'm cheering you on.",
    //            "You make a difference.",
    //            "You've got the strength to do this.",
    //            "I'm with you every step of the way.",
    //            "You can overcome any obstacle.",
    //            "You are more powerful than you know.",
    //            "You bring so much to the table.",
    //            "You are capable of great things.",
    //            "I'm here to lift you up.",
    //            "You inspire those around you.",
    //            "You're a rock star.",
    //            "You're doing so well.",
    //            "You're going to get through this.",
    //            "I'm your biggest fan.",
    //            "You've got all the strength you need.",
    //            "You have what it takes.",
    //            "I'm here to help you shine.",
    //            "You are amazing just as you are.",
    //            "You're a true warrior.",
    //            "You're unstoppable.",
    //            "You can handle this.",
    //            "You are destined for greatness.",
    //            "You light up the world.",
    //            "I'm here, no matter what.",
    //            "You're doing just fine.",
    //            "You're a superhero.",
    //            "You are so brave.",
    //            "You inspire me to be better.",
    //            "You are a source of strength.",
    //            "You're making progress every day.",
    //            "You are resilient.",
    //            "You've come so far.",
    //            "I'm so proud of your courage.",
    //            "You are capable of amazing things.",
    //            "You have a heart of gold.",
    //            "You are so courageous.",
    //            "You are so determined.",
    //            "You've got the heart of a lion.",
    //            "You are a beacon of strength.",
    //            "You're a force to be reckoned with.",
    //            "You have a warrior's heart.",
    //            "You are a true hero.",
    //            "You are a shining light.",
    //            "You are capable of anything.",
    //            "You are an inspiration.",
    //            "You have an unbreakable spirit.",
    //            "You are so loved.",
    //            "You have the strength to keep going.",
    //            "You are a beacon of hope.",
    //            "You are making a difference.",
    //            "You are doing incredible things.",
    //            "You are a true champion.",
    //            "You are capable of overcoming anything.",
    //            "You are so strong.",
    //            "You are so brave and courageous.",
    //            "You have the heart of a warrior.",
    //            "You are a light in the darkness.",
    //            "You are a true inspiration.",
    //            "You have a heart of steel.",
    //            "You are a true fighter.",
    //            "You are a true warrior of strength.",
    //            "You are an unstoppable force.",
    //            "You are a beacon of love.",
    //            "You are capable of great things.",
    //            "You are a true legend.",
    //            "You are a hero in my eyes.",
    //            "You are a shining star.",
    //            "You have a heart full of strength.",
    //            "You are a pillar of strength.",
    //            "You are a source of courage.",
    //            "You are a beacon of bravery.",
    //            "You have a spirit of a warrior.",
    //            "You are a true inspiration to all.",
    //            "You are a force of nature.",
    //            "You are an embodiment of strength.",
    //            "You are a true symbol of courage.",
    //            "You have a heart of a champion.",
    //            "You are an example of resilience.",
    //            "You are a true emblem of power.",
    //            "You have a soul of a warrior.",
    //            "You are a true fighter of life.",
    //            "You are a living testament to strength."
    //        ],
    //        "intimacy": [
    //            "Your touch drives me wild.",
    //            "I crave the feel of your skin.",
    //            "Being close to you is my favorite feeling.",
    //            "I love the way you hold me.",
    //            "Your kisses are addictive.",
    //            "I can't get enough of your warmth.",
    //            "You set my soul on fire.",
    //            "I love how you make me feel.",
    //            "I can't wait to be alone with you.",
    //            "You make my heart race.",
    //            "I love being wrapped up in your arms.",
    //            "Your embrace feels like home.",
    //            "I love the way you look at me.",
    //            "Your scent is intoxicating.",
    //            "I can't get enough of you.",
    //            "Your touch sends shivers down my spine.",
    //            "I love feeling close to you.",
    //            "Your kisses make everything better.",
    //            "You make my heart skip a beat.",
    //            "I love the way you make me feel alive.",
    //            "I want to be closer to you.",
    //            "You are my favorite escape.",
    //            "I love the way you touch me.",
    //            "Your body against mine is perfect.",
    //            "I can't get enough of your touch.",
    //            "I want to feel you next to me.",
    //            "You make my heart race with desire.",
    //            "You make me feel so alive.",
    //            "I want to be lost in your touch.",
    //            "You make my heart beat faster.",
    //            "I want to feel you close.",
    //            "I love the way you hold me tight.",
    //            "You are my desire.",
    //            "I want to be closer than close.",
    //            "I crave your kisses.",
    //            "Your touch is electric.",
    //            "I want to feel your warmth.",
    //            "You make my heart flutter.",
    //            "I want to be in your arms forever.",
    //            "Your touch is my weakness.",
    //            "I want to feel your heartbeat.",
    //            "You make my heart race with passion.",
    //            "I want to feel you next to me.",
    //            "You make my heart skip a beat.",
    //            "I want to be closer than ever.",
    //            "You make me feel alive with every touch.",
    //            "I want to be lost in you.",
    //            "You are my favorite feeling.",
    //            "I want to feel you closer.",
    //            "You make my heart beat faster.",
    //            "I want to be close to you.",
    //            "You are my desire and my dream.",
    //            "I want to feel your warmth.",
    //            "You are my favorite escape.",
    //            "I want to feel you close.",
    //            "You are my passion.",
    //            "I want to be lost in your touch.",
    //            "You are my favorite place to be.",
    //            "I want to be close to your heart.",
    //            "You make my heart race with love.",
    //            "I want to be close to you forever.",
    //            "You make my heart skip a beat.",
    //            "I want to be close to you.",
    //            "You are my favorite embrace.",
    //            "I want to feel you next to me.",
    //            "You make my heart race.",
    //            "I want to be in your arms.",
    //            "You are my favorite touch.",
    //            "I want to be close to you always.",
    //            "You are my desire and my love.",
    //            "I want to feel your warmth.",
    //            "You make my heart flutter.",
    //            "I want to be close to you forever.",
    //            "You are my favorite feeling.",
    //            "I want to feel your heartbeat.",
    //            "You make my heart race with passion.",
    //            "I want to be close to your heart.",
    //            "You are my desire and my dream.",
    //            "I want to be in your arms forever.",
    //            "You make my heart skip a beat.",
    //            "I want to feel you next to me.",
    //            "You are my favorite embrace.",
    //            "I want to be close to you.",
    //            "You are my favorite place to be.",
    //            "I want to be close to your heart.",
    //            "You make my heart race.",
    //            "I want to be lost in your touch.",
    //            "You are my desire and my love.",
    //            "I want to be close to you forever.",
    //            "You make my heart skip a beat.",
    //            "I want to feel your warmth.",
    //            "You are my favorite escape.",
    //            "I want to feel you closer.",
    //            "You make my heart beat faster.",
    //            "I want to be in your arms.",
    //            "You are my favorite touch.",
    //            "I want to be close to you always.",
    //            "You are my desire and my dream.",
    //            "I want to feel your heartbeat.",
    //            "You make my heart flutter.",
    //            "I want to be close to your heart."
    //        ],
    //        "dirty": [
    //            "I can't stop thinking about our last night together.",
    //            "I want you to take me, right now.",
    //            "I crave every inch of you.",
    //            "I want to feel you inside me.",
    //            "I need your hands all over my body.",
    //            "I want to taste every part of you.",
    //            "I want to hear you moan my name.",
    //            "I need you, every bit of you.",
    //            "I want to feel you moving inside me.",
    //            "I want to make you lose control.",
    //            "I want to feel your lips on every part of my body.",
    //            "I want to be the reason you can't think straight.",
    //            "I need to feel you inside me.",
    //            "I want to make you beg for it.",
    //            "I can't wait to feel you deep inside me.",
    //            "I want you to take control of me.",
    //            "I want to make you scream my name.",
    //            "I need you inside me right now.",
    //            "I want you to make me yours.",
    //            "I can't stop imagining your hands on me.",
    //            "I need to feel your skin against mine.",
    //            "I want to taste you all night long.",
    //            "I want to feel you so deep inside me.",
    //            "I want you to make me yours.",
    //            "I need you so bad it hurts.",
    //            "I want to feel you all over me.",
    //            "I want to make you lose control.",
    //            "I need your body against mine.",
    //            "I want you to make me scream.",
    //            "I want to feel you everywhere.",
    //            "I need to feel you inside me.",
    //            "I want to make you lose your mind.",
    //            "I need you to take me now.",
    //            "I want to feel you deep inside.",
    //            "I want to taste every inch of you.",
    //            "I need you to make me yours.",
    //            "I want to feel you all over me.",
    //            "I want to be the reason you lose control.",
    //            "I want to make you moan my name.",
    //            "I need you inside me.",
    //            "I want you to make me yours.",
    //            "I want to feel you so deep.",
    //            "I want to taste you all night.",
    //            "I need you to take me.",
    //            "I want you to lose yourself in me.",
    //            "I want to feel you everywhere.",
    //            "I need to feel you inside me.",
    //            "I want to be your everything tonight.",
    //            "I want to feel you all night long.",
    //            "I need you so bad right now.",
    //            "I want you to take control.",
    //            "I want to feel you deep inside me.",
    //            "I want to make you scream.",
    //            "I need to feel your touch.",
    //            "I want to taste every inch of you.",
    //            "I need you inside me.",
    //            "I want you to take me completely.",
    //            "I want to feel you deep inside.",
    //            "I want to taste you all night long.",
    //            "I need you to take me now.",
    //            "I want you to be mine tonight.",
    //            "I want to feel you all over my body.",
    //            "I want to be yours tonight.",
    //            "I want to feel you deep within me.",
    //            "I need you so bad.",
    //            "I want to taste every inch of you.",
    //            "I need to feel you inside me.",
    //            "I want to be your everything tonight.",
    //            "I want to feel you deep inside.",
    //            "I need you to take me completely.",
    //            "I want to be the reason you lose control.",
    //            "I want to feel you everywhere.",
    //            "I want to make you moan.",
    //            "I need you inside me.",
    //            "I want you to be mine.",
    //            "I want to feel you so deep.",
    //            "I want to taste every inch of you.",
    //            "I need you so bad right now.",
    //            "I want you to take control of me.",
    //            "I want to be yours tonight.",
    //            "I want to feel you everywhere.",
    //            "I need to feel you inside me.",
    //            "I want you to make me yours.",
    //            "I want to be the reason you lose control.",
    //            "I want to feel you all over me.",
    //            "I want to make you moan my name.",
    //            "I need you inside me.",
    //            "I want you to take me completely.",
    //            "I want to feel you so deep.",
    //            "I want to taste you all night.",
    //            "I need you to take me now.",
    //            "I want you to lose yourself in me.",
    //            "I want to feel you everywhere.",
    //            "I need to feel you inside me."
    //        ]
    //    ]
    
    
    
    
    // Messages separated by category and gender
    static let messages: [String: [Gender: [String]]] = [
        "love": [
            .general: [
                "You're my safe place.",
                "Your smile makes my day.",
                "You're my greatest adventure.",
                "You complete me in every way.",
                "With you, everything feels right.",
                "I can't imagine life without you.",
                "My heart beats just for you.",
                "You're my sunshine on a cloudy day.",
                "You light up my life.",
                "Every day with you is a blessing.",
                "You're my favorite hello and hardest goodbye.",
                "I love you more than words can say.",
                "You make every moment special.",
                "You're my perfect match.",
                "I'm so lucky to have you.",
                "You're the reason I believe in love.",
                "Being with you is my favorite thing.",
                "My heart belongs to you, always.",
                "I adore everything about you.",
                "You make my world a better place.",
                "You're the best part of my life.",
                "You are my forever.",
                "My love for you grows every day.",
                "You are my person.",
                "You have my heart.",
                "I'm so grateful for you.",
                "You're my one and only.",
                "You're my everything.",
                "I love the way you make me feel.",
                "You're the one I want to spend my life with.",
                "You make my heart race.",
                "I'm happiest when I'm with you.",
                "I love being by your side.",
                "You're my home.",
                "You make me feel so loved.",
                "You're my dream come true.",
                "I love every little thing about you.",
                "You are my happiness.",
                "You make my heart smile.",
                "You're the love of my life.",
                "I can't stop thinking about you.",
                "I love you more every day.",
                "You make everything better.",
                "You mean the world to me.",
                "You're my forever and always.",
                "You're my favorite person to talk to.",
                "You're the best thing that ever happened to me.",
                "You make me believe in love.",
                "You and me, always.",
                "I'm so lucky to be with you.",
                "You're my greatest treasure.",
                "You have my heart completely.",
                "You're my endless love.",
                "You bring joy to my life.",
                "I love you to the moon and back.",
                "You're my one true love.",
                "You're my better half.",
                "I can't wait to spend forever with you.",
                "You're my heart's desire.",
                "You make my soul happy.",
                "You fill my life with love.",
                "You are my everything.",
                "You complete my life.",
                "You are my sweetest dream.",
                "I love being with you.",
                "You're my heart's song.",
                "You make my life complete.",
                "You're my love story.",
                "You make my heart skip a beat.",
                "You are my happy place.",
                "You're my endless love.",
                "You are the reason I smile.",
                "You make every day better.",
                "You're my heart's keeper.",
                "You are my heart.",
                "You make me feel alive.",
                "You are my favorite person.",
                "You make my heart sing.",
                "You're my everything and more.",
                "You are my love, my life.",
                "You are my best friend and my love.",
                "You're the love of my life.",
                "You are my reason to be happy.",
                "You're my world.",
                "You are my one and only love.",
                "You make my heart soar.",
                "You make my life beautiful.",
                "You are my greatest love.",
                "You are my forever love.",
                "You're the reason I smile every day.",
                "You make my world go round.",
                "You are my perfect love.",
                "You are my true love.",
                "You make me believe in fairy tales.",
                "You are my heart and soul.",
                "You are my one true love.",
                "You make my dreams come true.",
                "You are my happy ending.",
                "You are my sweet escape.",
                "You are my everything, always.",
                "You are my love and my light.",
                "You are my heart's one desire.",
                "You are my one and only dream."
            ]
        ],
        "supportive": [
            .general: [
                "You've got this!",
                "I'm so proud of you.",
                "You are stronger than you think.",
                "I'm here for you, always.",
                "Keep pushing forward.",
                "You inspire me every day.",
                "You're capable of amazing things.",
                "I believe in you.",
                "You're doing an amazing job.",
                "I'm right by your side.",
                "You make me proud.",
                "You're a fighter.",
                "You can do anything you set your mind to.",
                "I'm here to support you.",
                "You're not alone in this.",
                "You have my full support.",
                "I'm cheering you on.",
                "You make a difference.",
                "You've got the strength to do this.",
                "I'm with you every step of the way.",
                "You can overcome any obstacle.",
                "You are more powerful than you know.",
                "You bring so much to the table.",
                "You are capable of great things.",
                "I'm here to lift you up.",
                "You inspire those around you.",
                "You're a rock star.",
                "You're doing so well.",
                "You're going to get through this.",
                "I'm your biggest fan.",
                "You've got all the strength you need.",
                "You have what it takes.",
                "I'm here to help you shine.",
                "You are amazing just as you are.",
                "You're a true warrior.",
                "You're unstoppable.",
                "You can handle this.",
                "You are destined for greatness.",
                "You light up the world.",
                "I'm here, no matter what.",
                "You're doing just fine.",
                "You're a superhero.",
                "You are so brave.",
                "You inspire me to be better.",
                "You are a source of strength.",
                "You're making progress every day.",
                "You are resilient.",
                "You've come so far.",
                "I'm so proud of your courage.",
                "You are capable of amazing things.",
                "You have a heart of gold.",
                "You are so courageous.",
                "You are so determined.",
                "You've got the heart of a lion.",
                "You are a beacon of strength.",
                "You're a force to be reckoned with.",
                "You have a warrior's heart.",
                "You are a true hero.",
                "You are a shining light.",
                "You are capable of anything.",
                "You are an inspiration.",
                "You have an unbreakable spirit.",
                "You are so loved.",
                "You have the strength to keep going.",
                "You are a beacon of hope.",
                "You are making a difference.",
                "You are doing incredible things.",
                "You are a true champion.",
                "You are capable of overcoming anything.",
                "You are so strong.",
                "You are so brave and courageous.",
                "You have the heart of a warrior.",
                "You are a light in the darkness.",
                "You are a true inspiration.",
                "You have a heart of steel.",
                "You are a true fighter.",
                "You are a true warrior of strength.",
                "You are an unstoppable force.",
                "You are a beacon of love.",
                "You are capable of great things.",
                "You are a true legend.",
                "You are a hero in my eyes.",
                "You are a shining star.",
                "You have a heart full of strength.",
                "You are a pillar of strength.",
                "You are a source of courage.",
                "You are a beacon of bravery.",
                "You have a spirit of a warrior.",
                "You are a true inspiration to all.",
                "You are a force of nature.",
                "You are an embodiment of strength.",
                "You are a true symbol of courage.",
                "You have a heart of a champion.",
                "You are an example of resilience.",
                "You are a true emblem of power.",
                "You have a soul of a warrior.",
                "You are a true fighter of life.",
                "You are a living testament to strength."
            ]
        ],
        "intimacy": [
            .man: [
                "Your touch drives me wild.",
                "I crave the feel of your skin.",
                "Being close to you is my favorite feeling.",
                "I love the way you hold me.",
                "Your kisses are addictive.",
                "I can't get enough of your warmth.",
                "You set my soul on fire.",
                "I love how you make me feel.",
                "I can't wait to be alone with you.",
                "You make my heart race.",
                "I love being wrapped up in your arms.",
                "Your embrace feels like home.",
                "I love the way you look at me.",
                "Your scent is intoxicating.",
                "I can't get enough of you.",
                "Your touch sends shivers down my spine.",
                "I love feeling close to you.",
                "Your kisses make everything better.",
                "You make my heart skip a beat.",
                "I love the way you make me feel alive."
            ],
            .woman: [
                "Your touch drives me wild.",
                "I crave the feel of your skin.",
                "I love the way you hold me.",
                "Your kisses are addictive.",
                "I can't wait to feel you inside me.",
                "I need your hands all over my body.",
                "You set my soul on fire.",
                "You make my heart race with desire.",
                "I want to feel you next to me.",
                "I can't wait to be alone with you.",
                "Your scent is intoxicating.",
                "You make my heart race with passion."
            ],
            .general: [
                "I love being wrapped up in your arms.",
                "You make me feel alive with every touch.",
                "I want to feel your warmth.",
                "You make my heart beat faster.",
                "I love the way you hold me tight."
            ]
        ],
        "dirty": [
            .man: [
                "I want to feel your lips on every part of my body.",
                "I want to make you scream my name.",
                "I want to make you lose control.",
                "I want to feel you deep inside.",
                "I want to taste every inch of you.",
                "I want you to take control.",
                "I want to be the reason you lose control.",
                "I want to make you moan.",
                "I want to feel you all over me.",
                "I want to make you beg for it.",
                "I need to feel your skin against mine.",
                "I can't wait to feel you on me.",
                "I want to taste you all night long.",
                "I want to make you scream my name."
            ],
            .woman: [
                "I can't stop thinking about our last night together.",
                "I want to feel you inside me.",
                "I need you inside me right now.",
                "I can't wait to feel you deep inside me.",
                "I want you to take me, right now.",
                "I crave every inch of you.",
                "I want to feel you moving inside me.",
                "I want to taste every part of you.",
                "I want to hear you moan my name.",
                "I need your hands all over my body.",
                "I want to feel you so deep inside me.",
                "I need you so bad it hurts.",
                "I want you to take control of me.",
                "I want to make you scream."
            ],
            .general: [
                "I want to make you lose control.",
                "I want to feel you all over me.",
                "I can't wait to feel you close.",
                "I want to taste you.",
                "I need you so bad right now.",
                "I want to feel your body next to mine.",
                "I can't stop imagining your hands on me.",
                "I want you so bad right now.",
                "I want you to be mine tonight.",
                "I want you to lose yourself in me.",
                "I want to feel your heartbeat against mine.",
                "I want to be your everything tonight."
            ]
        ]
    ]
    
    
    
    
    
    
    
    
    
    // Function to get a random message based on category and gender
    static func getRandomMessage(from category: CDMessageCategory, for gender: Gender) -> String? {
        if let genderMessages = CDMessageHelper.messages[category.rawValue]?[gender], !genderMessages.isEmpty {
            return genderMessages.randomElement()
        } else if let generalMessages = CDMessageHelper.messages[category.rawValue]?[.general], !generalMessages.isEmpty {
            return generalMessages.randomElement()
        } else {
            return nil
        }
    }
    
    
    
    static func sendRandomMessageBasedOnGender(category: CDMessageHelper.CDMessageCategory, userGender: String) -> String? {
        // Step 1: Map the string gender to the Gender enum
        let gender: CDMessageHelper.Gender = {
            switch userGender {
            case "Male":
                return .man
            case "Female":
                return .woman
            default:
                return .general
            }
        }()
        
        // Step 2: Randomly decide whether to use a gender-specific or general message
        let useGenderSpecificMessage = Bool.random()  // Randomly chooses true or false
        
        if useGenderSpecificMessage {
            // Step 3: Try to get a gender-specific message
            if let genderMessage = CDMessageHelper.getRandomMessage(from: category, for: gender) {
                print("Sending gender-specific message: \(genderMessage)")
                // Here you would send the message or use it in your app
                return genderMessage
            }
        }
        
        // Step 4: Fallback to general message if gender-specific is not chosen or not available
        if let generalMessage = CDMessageHelper.getRandomMessage(from: category, for: .general) {
            print("Sending general message: \(generalMessage)")
            return generalMessage

            // Here you would send the message or use it in your app
        } else {
            print("No message available for the selected category.")
            return nil
        }
    }

    
    
}


extension UITextView {
    
    func addHyperLinksToText(originalText: String, hyperLinks: [String: String]) {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        for (hyperLink, urlString) in hyperLinks {
            let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
            let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
            attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
            attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: self.font ?? UIFont.systemFont(ofSize: 10), range: fullRange)
        }
        
        self.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        self.textAlignment = .center
        self.attributedText = attributedOriginalText
    }
}


struct PhoneHelper {
    static func getCountryCode() -> String {
        guard let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider, let countryCode = carrier.isoCountryCode else { return "+1" }
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        
        if(countryCode.uppercased() == "--") {
            return "+1"
        }
        let countryDialingCode = prefixCodes[countryCode.uppercased()] ?? ""
        return "+" + countryDialingCode
    }
}
