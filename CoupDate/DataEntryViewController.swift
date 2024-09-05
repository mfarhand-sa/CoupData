import UIKit
import Lottie

class DataEntryViewController: UIViewController, UITextViewDelegate {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let poopCardView = UIView()
    private let poopAnimationView = LottieAnimationView(name: "Poop")
    private let poopYesButton = UIButton(type: .system)
    private let poopNoButton = UIButton(type: .system)
    
    private let sleepCardView = UIView()
    private let sleepAnimationView = LottieAnimationView(name: "Sleeping")
    private let sleepOptionAButton = UIButton(type: .system)
    private let sleepOptionBButton = UIButton(type: .system)
    private let sleepOptionCButton = UIButton(type: .system)
    
    private let detailsTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    
    private var selectedPoopStatus: String?
    private var selectedSleepOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        
        // Tap gesture to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        detailsTextView.delegate = self
        
        // Add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupUI() {
        // Configure scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Configure card views
        configureCardView(poopCardView, animationView: poopAnimationView, buttons: [poopYesButton, poopNoButton])
        configureCardView(sleepCardView, animationView: sleepAnimationView, buttons: [sleepOptionAButton, sleepOptionBButton, sleepOptionCButton])
        
        // Layout stack view
        let stackView = UIStackView(arrangedSubviews: [poopCardView, sleepCardView, detailsTextView, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Configure buttons
        configureButton(poopYesButton, title: "YES 🍑 💩", action: #selector(poopYesTapped))
        configureButton(poopNoButton, title: "NO 🍑", action: #selector(poopNoTapped))
        configureButton(sleepOptionAButton, title: "1-4 hrs 😵", action: #selector(sleepOptionATapped))
        configureButton(sleepOptionBButton, title: "6-8 hrs 🥳", action: #selector(sleepOptionBTapped))
        configureButton(sleepOptionCButton, title: "4-6 hrs 😔", action: #selector(sleepOptionCTapped))
        
        // Configure text view
        detailsTextView.layer.cornerRadius = 12
        detailsTextView.layer.borderWidth = 1
        detailsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        detailsTextView.backgroundColor = .secondarySystemBackground
        detailsTextView.textColor = .label
        detailsTextView.font = UIFont(name:"Poppins-Regular", size: 16)
        detailsTextView.translatesAutoresizingMaskIntoConstraints = false
        detailsTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Configure save button
        configureSaveButton()
        
        // Adjust scroll view content inset for tab bar
        adjustScrollViewForTabBar()
    }
    
    private func adjustScrollViewForTabBar() {
        guard let tabBarHeight = tabBarController?.tabBar.frame.height else { return }
        scrollView.contentInset.bottom = tabBarHeight
        scrollView.scrollIndicatorInsets.bottom = tabBarHeight
    }

    private func configureCardView(_ cardView: UIView, animationView: LottieAnimationView, buttons: [UIButton]) {
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.separator.cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 8
        cardView.layer.masksToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            animationView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            animationView.heightAnchor.constraint(equalToConstant: 120),
            animationView.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.6)
        ])
        
        let buttonStackView = UIStackView(arrangedSubviews: buttons)
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            buttonStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name:"Poppins-Light", size: 14)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1.5
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        if traitCollection.userInterfaceStyle == .dark {
            button.backgroundColor = UIColor.systemGray5
            button.layer.borderColor = UIColor.white.cgColor
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = UIColor.systemGray6
            button.layer.borderColor = UIColor.systemGray.cgColor
            button.setTitleColor(.label, for: .normal)
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height

        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
        
        // Adjust the scroll view offset to make the text view visible
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + keyboardHeight)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Update all buttons appearance when interface style changes
            [poopYesButton, poopNoButton, sleepOptionAButton, sleepOptionBButton, sleepOptionCButton, saveButton].forEach {
                updateButtonAppearance(button: $0)
            }
        }
    }

    private func updateButtonAppearance(button: UIButton) {
        if traitCollection.userInterfaceStyle == .dark {
            button.layer.borderColor = UIColor.white.cgColor
            button.setTitleColor(.white, for: .normal)
        } else {
            button.layer.borderColor = UIColor.systemGray.cgColor
            button.setTitleColor(.label, for: .normal)
        }
    }
    
    private func configureSaveButton() {
        saveButton.setTitle("Save Data", for: .normal)
        saveButton.titleLabel?.font = UIFont(name:"Poppins-Bold", size: 18)
        saveButton.backgroundColor = UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveButton.layer.shadowOpacity = 0.2
        saveButton.layer.shadowRadius = 4
        saveButton.addTarget(self, action: #selector(saveData), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func poopYesTapped() {
        selectedPoopStatus = "YES 🍑 💩"
        updatePoopSelection(for: poopYesButton)
    }
    
    @objc private func poopNoTapped() {
        selectedPoopStatus = "NO 🍑"
        updatePoopSelection(for: poopNoButton)
    }
    
    @objc private func sleepOptionATapped() {
        selectedSleepOption = "1-4 hrs 😵"
        updateSleepSelection(for: sleepOptionAButton)
    }
    
    @objc private func sleepOptionBTapped() {
        selectedSleepOption = "6-8 hrs 🥳"
        updateSleepSelection(for: sleepOptionBButton)
    }
    
    @objc private func sleepOptionCTapped() {
        selectedSleepOption = "4-6 hrs 😔"
        updateSleepSelection(for: sleepOptionCButton)
    }
    
    @objc private func saveData() {
        let poopStatus = selectedPoopStatus ?? "No Data"
        let sleepOption = selectedSleepOption ?? "No Data"
        let details = detailsTextView.text ?? ""
        
        let currentDate = Date()
        
        FirebaseManager.shared.saveDailyRecord(for: UserManager.shared.userID!, date: currentDate, poopStatus: poopStatus, poopDetails: details, sleepStatus: sleepOption, sleepDetails: details) { result in
            switch result {
            case .success():
                print("Data saved successfully")
                self.detailsTextView.resignFirstResponder()
            case .failure(let error):
                print("Error saving data: \(error)")
            }
        }
    }
    
    private func updatePoopSelection(for button: UIButton) {
        [poopYesButton, poopNoButton].forEach {
            $0.backgroundColor = .secondarySystemBackground
            $0.setTitleColor(.label, for: .normal)
        }
        button.backgroundColor = UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
    }
    
    private func updateSleepSelection(for button: UIButton) {
        [sleepOptionAButton, sleepOptionBButton, sleepOptionCButton].forEach {
            $0.backgroundColor = .secondarySystemBackground
            $0.setTitleColor(.label, for: .normal)
        }
        button.backgroundColor = UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
