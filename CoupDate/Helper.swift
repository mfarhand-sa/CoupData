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

    
        func capitalizingFirstLetter() -> String {
            return prefix(1).capitalized + dropFirst()
        }

        mutating func capitalizeFirstLetter() {
            self = self.capitalizingFirstLetter()
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

            // Transition animation block
            UIView.transition(with: window, duration: 0.5, options: [.transitionCrossDissolve], animations: {
                window.isUserInteractionEnabled = false // Disable interaction during transition
                window.rootViewController = viewController
            }, completion: { _ in
                window.makeKeyAndVisible()
                
                // Re-enable user interaction after transition
                window.isUserInteractionEnabled = true

                // Remove any lingering animations from the window layer
                window.layer.removeAllAnimations()

                // Delay the keyboard activation further to allow UI to fully settle
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Adjust this delay as needed
                    viewController.becomeFirstResponder()
                    print("Attempting to make \(viewController) the first responder after transition.")
                }
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

