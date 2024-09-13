import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import Lottie
import Combine

class CoupleLoginViewController: UIViewController {
    
    // UI Components
    private let googleSignInButton = GIDSignInButton()
    private let appleSignInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    private let animationView = LottieAnimationView(name: "LoginAnimtation")
    
    // Partner View Model
    private var partnerViewModel = PartnerViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    var hasNavigatedToMainScreen : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "CDBackground")
        
        setupLottieAnimation()
        setupSignInButtons()
        setupLayout()
        
        
    }
    
    // Setup Lottie animation
    private func setupLottieAnimation() {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
    }
    
    
    // Setup layout constraints
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Lottie animation constraints
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            animationView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            // Google Sign-In button constraints
            googleSignInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Apple Sign-In button constraints
            appleSignInButton.bottomAnchor.constraint(equalTo: googleSignInButton.topAnchor, constant: -20),
            appleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Setup sign-in buttons
    private func setupSignInButtons() {
        // Configure Google Sign-In button
        googleSignInButton.style = .wide
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(googleSignInButton)
        
        
        // Optional: Add target action for sign-in
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        
        
        // Configure Apple Sign-In button
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appleSignInButton)
    }
    
    // MARK: - Google Sign-In
    
    @objc private func googleSignInTapped() {
        // Ensure configuration is set up
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        // Present the sign-in view controller
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil, let signInResult = signInResult else {
                print("Error signing in with Google: \(String(describing: error?.localizedDescription))")
                CustomAlerts.displayNotification(title: "", message: "Error signing in with Google: \(String(describing: error?.localizedDescription))", view: self.view)
                
                return
            }
            
            // Retrieve the ID token and Google credential
            guard let idToken = signInResult.user.idToken?.tokenString else { return }
            let accessToken = signInResult.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Sign in to Firebase with the Google credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in with Google error: \(error.localizedDescription)")
                    CustomAlerts.displayNotification(title: "", message: "Firebase sign in with Google error: \(error.localizedDescription)", view: self.view)
                } else {
                    print("User signed in with Google successfully")
                    
                    // Handle successful sign-in
                    if let user = authResult?.user {
                        let userRef = Firestore.firestore().collection("users").document(user.uid)
                        
                        userRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                // User document already exists
                                print("User document already exists.")
                            } else {
                                // Create new user document in Firestore
                                let userData: [String: Any] = [
                                    "email": user.email ?? "",
                                    "createdAt": FieldValue.serverTimestamp()
                                ]
                                userRef.setData(userData) { error in
                                    if let error = error {
                                        print("Error creating user document: \(error.localizedDescription)")
                                        DispatchQueue.main.async {
                                            CustomAlerts.displayNotification(title: "", message: "Error creating user document: \(error.localizedDescription)", view: self.view)
                                        }
                                        
                                    } else {
                                        print("User document created successfully!")
                                        // Handle successful sign-in here
                                        DispatchQueue.main.async {
                                            UserDefaults.standard.setValue("YES", forKey: "loggedIn")
                                            self.navigateToMainScreen() // Navigate after successful sign-in
                                        }
                                        
                                    }
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
    }
    // MARK: - Apple Sign-In
    
    @objc private func appleSignInTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    
    private func showRegistrationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let registrationVC = storyboard.instantiateViewController(withIdentifier: "CDUserRegistrationViewController") as! CDUserRegistrationViewController
        registrationVC.status = .fullName
        registrationVC.viewModel = self.partnerViewModel
        self.updateRootViewController(to: registrationVC)
    }
    
    
    private func showMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Instantiate the UITabBarController from the storyboard
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbar") as? CDTabbarController else {
            print("Could not find UITabBarController with identifier 'MainTabbar'")
            return
        }
        tabBarVC.viewModel = self.partnerViewModel
        updateRootViewController(to: tabBarVC)
    }
    
    
    private func checkAuthenticationAndLoadPartnerData() {
        // Wait for partner data to be loaded before navigating to the main screen
        partnerViewModel.$poopData
            .combineLatest(partnerViewModel.$sleepData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] poopData, sleepData in
                guard let self = self else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if let user = Auth.auth().currentUser, let _ = UserDefaults.standard.string(forKey: "loggedIn") {
                        print("User is already signed in: \(user.uid)")
                        self.navigateToMainScreen()
                    } else {
                        print("No user is signed in.")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    
    func navigateToMainScreen() {
        partnerViewModel.$userInfoRequired
            .combineLatest(partnerViewModel.$isLoading)
            .filter { !$1 } // Proceed only when not loading
            .flatMap { [weak self] (userInfoRequired: Bool, isLoading: Bool) -> AnyPublisher<Bool, Never> in
                guard let self = self else { return Just(false).eraseToAnyPublisher() }

                if userInfoRequired {
                    // If user info is required, show the registration screen
                    self.showRegistrationScreen()
                    return Just(false).eraseToAnyPublisher() // Prevent further navigation
                } else {
                    // Ensure the main screen is shown only once
                    if !self.hasNavigatedToMainScreen {
                        self.showMainScreen()
                        self.hasNavigatedToMainScreen = true
                    }
                    return Just(false).eraseToAnyPublisher() // Stop further navigation
                }
            }
            .receive(on: DispatchQueue.main) // Use explicit DispatchQueue.main
            .sink(receiveValue: { [weak self] (shouldNavigate: Bool) in
                guard let self = self, shouldNavigate else { return }
                self.checkAuthenticationAndLoadPartnerData()
            })
            .store(in: &cancellables)
        
        partnerViewModel.loadMyDataAndThenPartnerData()
    }}


// MARK: - ASAuthorizationControllerDelegate

extension CoupleLoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Fix here: Direct assignment instead of optional binding
            let nonce = randomNonceString()
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                Haptic.vibrating()
                CustomAlerts.displayNotification(title: "", message: "Unable to fetch identity token", view: self.view)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                CustomAlerts.displayNotification(title: "", message: "Unable to serialize token string from data: \(appleIDToken.debugDescription)", view: self.view)
                Haptic.vibrating()
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    CustomAlerts.displayNotification(title: "", message: "Error authenticating: \(error.localizedDescription)", view: self.view)

                    return
                }
                print("User signed in with Apple successfully")
                UserDefaults.standard.setValue("YES", forKey: "loggedIn")
                // Handle successful sign-in here
                self.navigateToMainScreen() // Navigate after successful sign-in
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign-In failed: \(error.localizedDescription)")
        CustomAlerts.displayNotification(title: "", message: "Apple Sign-In failed: \(error.localizedDescription)", view: self.view)

    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension CoupleLoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: - Utilities

// Helper function to generate nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0..<16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if length == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}
