//
//  CDUserRegistrationViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-05.
//

import UIKit
import Typist
import Lottie

enum registrainMode {
    case fullName
    case registerPhoneNumber
    case verifyPhoneNumber
    case emailAddress
    case birthday
    case gender

    
}


class CDUserRegistrationViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField?
    @IBOutlet weak var nextButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var womanView: LottieAnimationView?
    @IBOutlet weak var manView: LottieAnimationView?
    @IBOutlet weak var nextButton: CDButton!
    
    public var status : registrainMode = .fullName
    
    public var gender : String?

    
    @IBOutlet weak var animationView: LottieAnimationView?
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @objc func backButton() {
        print("backAction")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.nextButton.setBackgroundColor(.accent, for: .normal)
        self.nextButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        
        
        print("View Did Load in CDUserRegistrationViewController")
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "ArrowLeft")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "ArrowLeft")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(backButton)
        )
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.setHidesBackButton(true, animated: true)
        configureKeyboard()
        applyUI()
        setupAnimation()
        
        
        
    }
    
    func setupAnimation() {
        
        if self.status != .gender {
            animationView!.contentMode = .scaleAspectFit
            animationView!.loopMode = .loop
            animationView!.animationSpeed = 1.0
            animationView!.play()
        } else {
            
            manView?.contentMode = .scaleAspectFit
            manView?.loopMode = .loop
            manView?.animationSpeed = 1.0
            manView?.play()
            
            womanView?.contentMode = .scaleAspectFit
            womanView?.loopMode = .loop
            womanView?.animationSpeed = 1.0
            womanView?.play()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Log window hierarchy to ensure view controller is in the right window
        if let window = self.view.window {
            print("Window found: \(window)")
        } else {
            print("No window found.")
        }
        // Force showing the keyboard
        self.inputTextField?.becomeFirstResponder() // Assuming there’s a text field to show the keyboard
    }
    
    func configureKeyboard() {
        
        let keyboard = Typist()
        keyboard
        
            .on(event: .willHide)  { [weak self] (options) in
                // Triggered when keyboard is dismissed non-interactively.
                print("willHide")
                self?.nextButtonConstraint.constant = 20
            }
        
            .on(event: .willShow)  { [weak self] (options) in
                // Triggered when keyboard is dismissed non-interactively.
                print("didShow")
                self?.nextButtonConstraint.constant = 310
            }
            .start()
        
    }
    
    func applyUI() {
        
        self.nextButton.setBackgroundColor(.accent, for: .normal)
        self.nextButton.setBackgroundColor(.lightGray, for: .disabled)
        self.nextButton.setTitleColor(UIColor.white, for: .normal)
        self.statusLabel.textColor = .CDText
        self.greetingLabel.textColor = .CDText
        self.inputTextField?.textColor = .CDText
        self.nextButton.isEnabled = (CDDataProvider.shared.name?.isEmpty == false)
        
        
        switch status {
            
        case .emailAddress:
            greetingLabel.text = "Your email address"
            inputTextField?.placeholder = "e.g. hello@leoio.com"
            inputTextField?.textContentType = .emailAddress
            self.statusLabel.text = "Done"
            
            break
            
        case .fullName:
            greetingLabel.text = "What should we call you?"
            inputTextField?.placeholder = "E.g. Sophia"
            self.statusLabel.text = "One more step"
            inputTextField?.textContentType = .name
            if let name = CDDataProvider.shared.name {
                inputTextField?.text = name
            }
            break
            
        case .birthday:
            
            // Set delegate for birthdayTextField
            if #available(iOS 17.0, *) {
                inputTextField?.textContentType = .birthdate
            } else {
                // Fallback on earlier versions
                inputTextField?.textContentType = nil
            }
            inputTextField?.delegate = self
            inputTextField?.keyboardType = .numberPad
            if #available(iOS 17.0, *) {
                inputTextField?.textContentType = .birthdate
            } else {
                // Fallback on earlier versions
            }
            greetingLabel.text = "When's your birthday \(CDDataProvider.shared.name!)? 🎂"
            
            let name = CDDataProvider.shared.name!
            let fullText = "When's your birthday \(name)? 🎂"
            // Create an NSMutableAttributedString
            let attributedString = NSMutableAttributedString(string: fullText)
            
            // Define the range of the name
            let nameRange = (fullText as NSString).range(of: name)
            
            // Apply bold font to the name
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: greetingLabel.font.pointSize), range: nameRange)
            
            // Assign the attributed text to the label
            greetingLabel.attributedText = attributedString
            
            inputTextField?.placeholder = "YYYYMMDD"
            self.statusLabel.text = "Almost done!"
            inputTextField?.textContentType = .name
            inputTextField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            self.nextButton.isEnabled = false
            
//            if let name = CDDataProvider.shared.birthday {
//                inputTextField.text = name
//            }
            
            break
            
        case .gender:
            greetingLabel.text = "What's your gender?"
            // Add tap gesture to lottieView1
            let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleTapOnManView))
            self.manView?.addGestureRecognizer(tapGesture1)
            self.manView?.isUserInteractionEnabled = true
            
            // Add tap gesture to lottieView2
            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTapOnWomanView))
            self.womanView?.addGestureRecognizer(tapGesture2)
            self.womanView?.isUserInteractionEnabled = true
            self.manView?.layer.borderWidth = 0.5
            self.womanView?.layer.borderWidth = 0.5
            self.nextButton.isEnabled = false

            break
            
        default : break
            
        }
        
        inputTextField?.borderStyle = UITextField.BorderStyle.none
        inputTextField?.layer.borderWidth = 1
        inputTextField?.layer.borderColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1).cgColor
        inputTextField?.layer.cornerRadius = 8.0
        inputTextField?.delegate = self
        inputTextField?.returnKeyType = .continue
    }
    
    
    @IBAction func nextAction(_ sender: CDButton) {
        
        switch status {
        case .fullName:
            // 1 phone validation
            print("The Fullname is : \(String(describing: self.inputTextField?.text))")
            print("FirstName :\(self.inputTextField?.text?.getTheFirstWord() ?? "")   LastName: \(self.inputTextField?.text?.getTheSecondWord() ?? "")")
            guard let name = self.inputTextField?.text else {
                CustomAlerts.displayNotification(title: "", message: "Please enter your name", view: self.view,fromBottom: false)
                return
            }
            
            if(self.isValid(name: name) == false) {
                CustomAlerts.displayNotification(title: "", message: "Please enter your name", view: self.view,fromBottom: false)
                return
            }
            Haptic.play()
            
            
            // 2 send the Full Name to the server
            sender.isEnabled = false
            
            
            FirebaseManager.shared.updateUserProfile(userID: UserManager.shared.currentUserID!, firstName: name, birthday: nil, partnerUserID: CDDataProvider.shared.partnerID) { result in
                
                switch result {
                case .success(let isSaved):
                    if isSaved {
                        print("Porfile has been updated!")
                        CDDataProvider.shared.name = name
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            sender.isEnabled = true
                            self.showRegistrationScreen(mode: .birthday)
                            
                        }
                        
                    } else {
                        sender.isEnabled = true
                        CustomAlerts.displayNotification(title: "", message: "Porfile hasn not been updated", view: self.view,fromBottom: false)
                    }
                case .failure(let error):
                    print("Failed to save partner user ID with error: \(error.localizedDescription)")
                    CustomAlerts.displayNotification(title: "", message: "Error in updating Porfile \(error)", view: self.view,fromBottom: false)
                    sender.isEnabled = true
                    
                }
            }
            
            
        case .birthday:
            
            let bday = convertBirthdayStringToDate(self.inputTextField!.text!)
            FirebaseManager.shared.updateUserProfile(userID: UserManager.shared.currentUserID!, firstName: CDDataProvider.shared.name!, birthday: bday, partnerUserID: CDDataProvider.shared.partnerID) { result in
                
                switch result {
                case .success(let isSaved):
                    if isSaved {
                        print("Partner user ID saved successfully.")
                        
                        CDDataProvider.shared.birthday = bday!
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            sender.isEnabled = true
                          //  CustomAlerts.displayNotification(title: "", message: "Porfile has been updated", view: self.view,fromBottom: false)
                            self.showRegistrationScreen(mode: .gender)
                        }
                        
                    } else {
                        sender.isEnabled = true
                        CustomAlerts.displayNotification(title: "", message: "Porfile hasn not been updated", view: self.view,fromBottom: false)
                    }
                case .failure(let error):
                    print("Failed to save partner user ID with error: \(error.localizedDescription)")
                    CustomAlerts.displayNotification(title: "", message: "Error in updating Porfile \(error)", view: self.view,fromBottom: false)
                    sender.isEnabled = true
                    
                }
            }
            
            break
            
            
        case .gender:
            
            FirebaseManager.shared.updateUserProfile(userID: UserManager.shared.currentUserID!, firstName: CDDataProvider.shared.name!, birthday: CDDataProvider.shared.birthday, partnerUserID: CDDataProvider.shared.partnerID,gender: self.gender) { result in
                
                switch result {
                case .success(let isSaved):
                    if isSaved {
                        print("Partner user ID saved successfully.")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            sender.isEnabled = true
                          //  CustomAlerts.displayNotification(title: "", message: "Porfile has been updated", view: self.view,fromBottom: false)
                            if let partnerId = CDDataProvider.shared.partnerID {
                                self.navigateToMainScreen()

                            } else {
                                self.navigateToInvitePartner()
                            }
                        }
                        
                    } else {
                        sender.isEnabled = true
                        CustomAlerts.displayNotification(title: "", message: "Porfile hasn not been updated", view: self.view,fromBottom: false)
                    }
                case .failure(let error):
                    print("Failed to save partner user ID with error: \(error.localizedDescription)")
                    CustomAlerts.displayNotification(title: "", message: "Error in updating Porfile \(error)", view: self.view,fromBottom: false)
                    sender.isEnabled = true
                    
                }
            }
            
            break
            
            
        default : break
        }
        
        
    }
    
    
    
    // MARK: - UITextFieldDelegate Methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text,status == .birthday else { return }
        
        // Remove slashes if user is typing
        let cleanText = text.replacingOccurrences(of: "/", with: "")
        
        // Add slashes after YYYY and MM
        let formattedText = formatBirthdayInput(cleanText)
        
        textField.text = formattedText
    }
    
    // Format the input string to "YYYY/MM/DD" format
    private func formatBirthdayInput(_ input: String) -> String {
        var result = ""
        let maxLength = 8
        
        // Limit the length to 8 characters (YYYYMMDD)
        let limitedInput = String(input.prefix(maxLength))
        
        // Loop through the characters and add slashes at positions 4 and 6
        for (index, char) in limitedInput.enumerated() {
            if index == 4 || index == 6 {
                result += "/"
            }
            result.append(char)
        }
        
        return result
    }
    
    // Handle deleting slashes as well
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        guard let currentText = textField.text as NSString? else {return true}
        // Build the new text
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        if status == .fullName {
            
            self.nextButton.isEnabled = newText.count >= 2
            return true
        }
        
        
        // Automatically insert "/" at the correct positions
        if string != "" { // Only do this when user is typing (not deleting)
            if newText.count == 4 || newText.count == 7 {
                textField.text = "\(newText)/"
                return false // Prevent manually adding the character
            }
        }
        
        // Enable the Next button if the format is valid, otherwise keep it disabled
        if isValidBirthdayFormat(newText) {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
        
        return true
    }
    
    
    // Optional: Disable the button again if user deletes the text and it's no longer valid
    func textFieldDidEndEditing(_ textField: UITextField) {
        if status == .birthday {
            if !isValidBirthdayFormat(textField.text ?? "") {
                nextButton.isEnabled = false
            }
        }
    }
    
    // Method to validate the birthday format (YYYY/MM/DD)
    func isValidBirthdayFormat(_ birthdayString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent date formatting

        // Check if the date string can be converted to a valid date
        guard let birthdayDate = dateFormatter.date(from: birthdayString) else {
            return false // Invalid date format
        }

        // Ensure the user is at least 18 years old
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthdayDate, to: now)

        guard let age = ageComponents.year, age >= 18 else {
            CustomAlerts.displayNotification(title: "Invalid Date of Birth", message: "You must be at least 18 years old to proceed.", view: self.view, fromBottom: false)

            return false // User is younger than 18
        }

        // Ensure the date is not in the future
        if birthdayDate > now {
            CustomAlerts.displayNotification(title: "", message: "Invalid Date of Birth", view: self.view, fromBottom: false)
            return false // Birthday cannot be in the future
        }

        return true
    }
    
    //validate name logic
    func isValid(name: String) -> Bool {
        
        guard name.count >= 2, name.count < 20 else { return false }
        let predicateTest = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$")
        return predicateTest.evaluate(with: name)
    }
    
    
    
    private func showRegistrationScreen(mode: registrainMode) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        var identifier = "CDUserRegistrationViewController"
        switch mode {
        case .gender:
            identifier = "CDUserGenederSelectionViewController"
            break
        default:
            break
        }
        
        let registrationVC = storyboard.instantiateViewController(withIdentifier: identifier) as! CDUserRegistrationViewController
        registrationVC.status = mode
        self.updateRootViewController(to: registrationVC)
    }
    
    
    
    
    func navigateToInvitePartner() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Find the PartnerActivityViewController in the tab bar's view controllers
        //        let pairingVC = storyboard.instantiateViewController(withIdentifier: "CDPairingViewController") as! CDPairingViewController
        //        pairingVC.mode = .invitation
        
        
        let pairingVC = storyboard.instantiateViewController(withIdentifier: "PartnerCodeViewController") as! PartnerCodeViewController
        
        // Set the UITabBarController as the root view controller
        updateRootViewController(to: pairingVC)
    }
    
    
    func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Instantiate the UITabBarController from the storyboard
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbar") as? CDTabbarController else {
            print("Could not find UITabBarController with identifier 'MainTabbar'")
            return
        }

        updateRootViewController(to: tabBarVC)
    }
    
    func convertBirthdayStringToDate(_ birthdayString: String) -> Date? {
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        
        // Set the date format matching the input string
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        // Convert the string to a Date object
        let date = dateFormatter.date(from: birthdayString)
        
        return date
    }
    
    
    @objc func handleTapOnManView() {
        print("Lottie View 1 tapped")
        // Handle Lottie View 1 tap action
        self.gender = "Male"
        self.manView?.layer.borderColor = UIColor.accent.cgColor
        self.womanView?.layer.borderColor = UIColor.lightGray.cgColor
        self.nextButton.isEnabled = true

    }

    @objc func handleTapOnWomanView() {
        print("Lottie View 2 tapped")
        self.gender = "Female"
        self.womanView?.layer.borderColor = UIColor.accent.cgColor
        self.manView?.layer.borderColor = UIColor.lightGray.cgColor
        self.nextButton.isEnabled = true

    }
    
}

