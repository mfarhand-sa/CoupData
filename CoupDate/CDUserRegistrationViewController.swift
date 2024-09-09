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
}


class CDUserRegistrationViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var nextButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: CDButton!
    
    public var status : registrainMode = .fullName
    
    @IBOutlet weak var animationView: LottieAnimationView!
    
    
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
        
        
        
        self.nextButton.setBackgroundColor(UIColor(named: "CDAccent"), for: .normal)
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
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 1.0
        animationView!.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        self.nextButton.setBackgroundColor(UIColor(named: "CDAccent"), for: .normal)
        self.nextButton.setBackgroundColor(.lightGray, for: .disabled)
        switch status {
            
        case .emailAddress:
            greetingLabel.text = "Your email address"
            inputTextField.placeholder = "e.g. hello@leoio.com"
            inputTextField.textContentType = .emailAddress
            self.statusLabel.text = "Done"
            break
            
        case .fullName:
            greetingLabel.text = "What should we call you?"
            inputTextField.placeholder = "E.g. Sophia"
            self.statusLabel.text = "One more step"
            inputTextField.textContentType = .name
            break
            
        case .birthday:
            
            // Set delegate for birthdayTextField
            inputTextField.delegate = self
            inputTextField.keyboardType = .numberPad
            if #available(iOS 17.0, *) {
                inputTextField.textContentType = .birthdate
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
            
            inputTextField.placeholder = "YYYYMMDD"
            self.statusLabel.text = "Almost done!"
            inputTextField.textContentType = .name
            inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            break
            
        default : break
            
        }
        inputTextField.borderStyle = UITextField.BorderStyle.none
        inputTextField.layer.borderWidth = 1
        inputTextField.layer.borderColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1).cgColor
        inputTextField.layer.cornerRadius = 8.0
        inputTextField.delegate = self
        inputTextField.becomeFirstResponder()
        inputTextField.returnKeyType = .continue
    }
    
    
    @IBAction func nextAction(_ sender: CDButton) {
        
        switch status {
        case .fullName:
            // 1 phone validation
            print("The Fullname is : \(String(describing: self.inputTextField.text))")
            print("FirstName :\(self.inputTextField.text?.getTheFirstWord() ?? "")   LastName: \(self.inputTextField.text?.getTheSecondWord() ?? "")")
            guard let name = self.inputTextField.text else {
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
                            CustomAlerts.displayNotification(title: "", message: "", view: self.view,fromBottom: false)
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
            
            
        case .emailAddress:
            print("The Email Address is : \(String(describing: self.inputTextField.text))")
            
            
            if(self.inputTextField.text?.isValidEmail()) == false {
                CustomAlerts.displayNotification(title: "", message: "The entered email is not valid. Please check it and try again!", view: self.view,fromBottom: false)
                return
            }
            
            
        case .birthday:
            
            let bday = convertBirthdayStringToDate(self.inputTextField.text!)
            FirebaseManager.shared.updateUserProfile(userID: UserManager.shared.currentUserID!, firstName: CDDataProvider.shared.name!, birthday: bday, partnerUserID: CDDataProvider.shared.partnerID) { result in
                
                switch result {
                case .success(let isSaved):
                    if isSaved {
                        print("Partner user ID saved successfully.")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            sender.isEnabled = true
                            CustomAlerts.displayNotification(title: "", message: "Porfile has been updated", view: self.view,fromBottom: false)
                            self.navigateToMainScreen()
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
        guard let currentText = textField.text as NSString?,status == .birthday else { return true }
        
        // Build the new text
        let newText = currentText.replacingCharacters(in: range, with: string)
        
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
        return dateFormatter.date(from: birthdayString) != nil
    }
    
    //validate name logic
    func isValid(name: String) -> Bool {
        
        guard name.count > 2, name.count < 20 else { return false }
        let predicateTest = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$")
        return predicateTest.evaluate(with: name)
    }
    
    
    
    private func showRegistrationScreen(mode: registrainMode) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let registrationVC = storyboard.instantiateViewController(withIdentifier: "CDUserRegistrationViewController") as! CDUserRegistrationViewController
        registrationVC.status = mode
        self.updateRootViewController(to: registrationVC)
    }
    
    
    func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Instantiate the UITabBarController from the storyboard
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbar") as? UITabBarController else {
            print("Could not find UITabBarController with identifier 'MainTabbar'")
            return
        }
        
        // Find the PartnerActivityViewController in the tab bar's view controllers
        if let partnerActivityVC = tabBarVC.viewControllers?.first(where: { $0 is PartnerActivityViewController }) as? PartnerActivityViewController {
        }
        
        // Set the UITabBarController as the root view controller
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
    
}

