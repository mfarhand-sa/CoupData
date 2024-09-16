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
    
    
    static let messages = [
        "love": [
            "You're my favorite person.",
            "Life is better with you.",
            "You mean everything to me.",
            "Every moment with you is magic.",
            "You complete my world.",
            "My heart belongs to you.",
            "I adore you more than words can say.",
            "You're the best part of my day.",
            "I cherish you endlessly.",
            "You and me, forever."
        ],
        "supportive": [
            "You've got this!",
            "I'm so proud of you.",
            "I'm here for you, always.",
            "You're stronger than you think.",
            "I believe in you.",
            "Keep going; you're amazing.",
            "I'll be your biggest cheerleader.",
            "You make me proud every day.",
            "You can conquer anything.",
            "I'll stand by you no matter what.",
            "You're doing great, don't forget that."
        ],
        "intimacy": [
            "Your touch drives me wild.",
            "I love feeling close to you.",
            "Your kisses are addicting.",
            "Being with you feels so right.",
            "I crave your warmth.",
            "I can't get enough of you.",
            "You make me feel alive.",
            "I love the way you hold me.",
            "Being in your arms is my favorite place.",
            "I feel so connected to you.",
            "You set my soul on fire."
        ],
        "dirty": [
            "I want to feel you deep inside me.",
            "I can't stop imagining your hands on my body.",
            "I love how you make me feel when we're together.",
            "I want to taste every inch of you.",
            "My body aches for you.",
            "I want to hear you moan my name.",
            "I need you inside me right now.",
            "Thinking of your body against mine drives me crazy.",
            "I can't wait to make you feel so good.",
            "I love how you make my body tremble.",
            "I want to feel you, every inch, every curve.",
            "I want to lose myself in your touch.",
            "I crave the way you move against me.",
            "I want to be the reason you can't breathe.",
            "I want to make you scream with pleasure.",
            "I need to feel you so bad.",
            "I want to make you beg for more.",
            "I can't wait to have you all to myself.",
            "I love the way you take control of me.",
            "I want to feel every bit of you until I can't think."
        ]
    ]
    
    
    
    
    static func getRandomMessage(from category: CDMessageCategory) -> String? {
        // Retrieve the messages for the given category
        if let categoryMessages = CDMessageHelper.messages[category.rawValue] {
            // Return a random message from the category
            return categoryMessages.randomElement()
        } else {
            // If the category is not found, return nil
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
