//
//  CDPhoneRegistrationViewController.swift
//  CoupDate
//
//  Created by mo on 2024-09-15.
//


import Foundation
import UIKit
import CountryPickerView
import Typist


class CDPhoneRegistrationViewController : UIViewController {
    
    @IBOutlet weak var nextButtonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: CDButton!
    @IBOutlet weak var privacyPolicyLabel: UITextView!
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    public var status : registrainMode = .registerPhoneNumber
    private var code : String = ""
    let cpvInternal = CountryPickerView()
    
    
    let keyboard = Typist()
    
    func configureKeyboard() {
        
        keyboard
        
            .on(event: .willChangeFrame) { (options) in
                // You are responsible animating inputAccessoryView
                print("willChangeFrame")
                
            }
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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configureKeyboard()
        applyUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.nextButton.setBackgroundColor(.black, for: .normal)
//        self.nextButton.setBackgroundColor(.lightGray, for: .disabled)
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        self.inputTextField?.resignFirstResponder()
    }
    
    @objc func backButton() {
        print("backAction")
        self.navigationController?.popViewController(animated: true)
    }
    
    func applyUI() {
        
        if (self.status == .verifyPhoneNumber ) {
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
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        switch status {
            
        case .registerPhoneNumber:
            inputTextField.borderStyle = UITextField.BorderStyle.none
            inputTextField.layer.borderWidth = 1
            inputTextField.layer.borderColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1).cgColor
            inputTextField.layer.cornerRadius = 8.0
            inputTextField.becomeFirstResponder()
            inputTextField.delegate = self
            cpvInternal.delegate = self
            cpvInternal.setCountryByName("Canada")
            cpvInternal.showCountryCodeInView = false
            greetingLabel.text = "Enter Your Phone Number"
            inputTextField.placeholder = "e.g. 6040000000"
            inputTextField.textContentType = .telephoneNumber
            inputTextField.keyboardType = .phonePad
            inputTextField.addTarget(self, action: #selector(yourHandler(textField:)), for: .editingChanged)
            // Line height: 20 pt
            privacyPolicyLabel.addHyperLinksToText(originalText: "By creating an account you agree \n with our friendly Privacy Policy and Terms", hyperLinks: ["Privacy Policy": "https://leoio.com/privacy-policy/","Terms":"https://leoio.com/terms-and-conditions/"])
            privacyPolicyLabel.textAlignment = .center
            let countryCode = PhoneHelper.getCountryCode()
            self.countryCodeButton.setTitle(countryCode, for: .normal)
            cpvInternal.setCountryByPhoneCode(countryCode)

                
                break
                
            case .verifyPhoneNumber:
                otpTextField.borderStyle = UITextField.BorderStyle.none
                otpTextField.layer.borderWidth = 1
                otpTextField.layer.borderColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1).cgColor
                otpTextField.layer.cornerRadius = 8.0
                otpTextField.textContentType = .oneTimeCode
                otpTextField.becomeFirstResponder()
                break
            default : break
                
            }
    }
    
    @objc final private func yourHandler(textField: UITextField) {
        print("Text changed")
        var tmp = textField.text?.removeWhitespace()
        tmp = tmp?.replace(string: "-", replacement: "")
        tmp = tmp?.replace(string: "(", replacement: "")
        tmp = tmp?.replace(string: ")", replacement: "")
        tmp = tmp?.replace(string: self.countryCodeButton.titleLabel?.text ?? "", replacement: "")
        textField.text = tmp
    }
    
    
    @IBAction func changeCountry(_ sender: Any) {
        Haptic.play()
        cpvInternal.showCountriesList(from: self)
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        
        Haptic.play()
        switch self.status {
        case .registerPhoneNumber:
            // 1 phone validation
            guard let result = inputTextField?.text?.isValidPhoneNumber() else {
                CustomAlerts.displayNotification(title: "", message: "Please check the entered phone number.", view: self.view,fromBottom: false)
                return
            }
            if result {
                print("Phone number is : \(cpvInternal.selectedCountry.phoneCode) + \(String(describing: self.inputTextField.text))")
                CDDataProvider.shared.countryCode = cpvInternal.selectedCountry.phoneCode
                CDDataProvider.shared.phoneNumber = self.inputTextField.text!
                
                // 2 send the phone number to the server
                sender.isEnabled = false
                FirebaseManager.shared.sendOTP("+" + cpvInternal.selectedCountry.phoneCode + self.inputTextField.text!) { success, error in
                    
                    if success == true {
                        sender.isEnabled = true
                        
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: .main)
                        let phoneRegistrationVC = storyboard.instantiateViewController(withIdentifier: "CDPhoneVerificationViewController") as! CDPhoneRegistrationViewController
                        phoneRegistrationVC.status = .verifyPhoneNumber
                        self.updateRootViewController(to: phoneRegistrationVC)
                        CustomAlerts.displayNotification(title: "", message: "Your verification code is on its way and will arrive in 2 minutes.", view: self.view,type: .message,fromBottom: false)
                    } else {
                        
                        sender.isEnabled = true
                        CustomAlerts.displayNotification(title: "", message: "Something is wrong. Please try again! - \(String(describing: error))", view: self.view,fromBottom: false,style: .warning)
                    }
                    
                }

                
            } else {
                // handle the error -- show warning
                print("error")
                DispatchQueue.main.async {
                    CustomAlerts.displayNotification(title: "", message: "Please check the entered phone number.", view: self.view,fromBottom: false)
                }
            }
            
        case .verifyPhoneNumber:
            
            // 1 OTP validation
            
             let result = (OTPVerification(_otp: self.otpTextField.text ?? ""))
            if (!result) {
                CustomAlerts.displayNotification(title: "", message: "Please check the entered code and try again.", view: self.view,fromBottom: false)
                return
            }
            // 2 send the entered otp code to the server and waiting for the result.
            
            sender.isEnabled = false
            
            
            FirebaseManager.shared.verifyOTP(self.otpTextField.text!) { success, userNeedMoreData, userHasData, partnerHasData, error in
                
                
                guard success else {
                    print("Oops, something went wrong")
                    DispatchQueue.main.async {
                        sender.isEnabled = true
                        CustomAlerts.displayNotification(title: "", message:"\(String(describing: error))" , view: self.view,fromBottom: false,style: .warning)
                    }
                    return
                }
                
                UserDefaults.standard.setValue("YES", forKey: "loggedIn")

                if userNeedMoreData {
                    
                    self.showRegistrationScreen()
                } else if userHasData || partnerHasData {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.navigateToMainScreen()
                    })
                    
                } else {
                    // Show the pairing screen if needed
                }
            }
                
        default:
            break
        }
        
        
    }
    
    func OTPVerification(_otp : String) -> Bool {
        
        return _otp.count==4
    }
    
    
    private func showRegistrationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let registrationVC = storyboard.instantiateViewController(withIdentifier: "CDUserRegistrationViewController") as! CDUserRegistrationViewController
        registrationVC.status = .fullName
        self.updateRootViewController(to: registrationVC)
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
    
}
//
extension CDPhoneRegistrationViewController: CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        let title = "Selected Country"
        let message = "Name: \(country.name) \nCode: \(country.code) \nPhone: \(country.phoneCode)"
        CDDataProvider.shared.countryCode = country.phoneCode
        self.countryCodeButton.setTitle(country.phoneCode, for: .normal)
        print(title,message)
    }
}




extension CDPhoneRegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {       //Special case code to handle the phone number field
        if string == "0" || string == "+" {
            if textField.text!.count == 0 {
                return false
            }
            return true
        }
        return true
    }
    
}






