

import UIKit
import Lottie
import Combine
import Firebase


class MessageListener {
    private var listener: ListenerRegistration?

    func listenForMessages() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }

        let messagesRef = Firestore.firestore().collection("users").document(currentUserUid).collection("messages")

        listener = messagesRef.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for document in documents {
                let data = document.data()
                let message = data["message"] as? String ?? ""
                let messageType = data["messageType"] as? String ?? "text"

                if messageType == "kiss" {
                    self.showKissAnimation()
                } else {
                    print("New message: \(message)")
                }

                // After processing, you may want to remove the message to avoid processing it again
                document.reference.delete()
            }
        }
    }

    func showKissAnimation() {
        // Show kiss animation on screen (e.g., a heart or kiss emoji floating across the screen)
        print("Showing kiss animation!")
    }

    func stopListening() {
        listener?.remove()
    }
}


class PartnerActivityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // UI Components
    let contentView = UIView()
    let greetingLabel = UILabel()
    
    var collectionView: UICollectionView!
    
//    public var viewModel : PartnerViewModel!
    
    let messageListener = MessageListener()
    
    // Example Data for Cards (This can be dynamic or fetched from a server)
    var cardData: [(title: String, animationName: String, data: [String: Any]?, BackgroundColour: UIColor)] = [
        ("Number Two News", "Poop", nil, .cdInsightBackground1),
        ("Sleep Tracker", "Sleeping", nil,.cdInsightBackground2),
        ("Vibe Check", "Mood", nil,.cdInsightBackground4),
        ("Energy Meter", "Energy", nil,.cdInsightBackground3)
    ]
    
    var poopData: [String: Any]?
    var sleepData: [String: Any]?
    var moodData: [String: Any]?
    var energyData: [String: Any]?

    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .CDBackground
        
        setupUI()
        setupCollectionView()
        self.poopData = CDDataProvider.shared.poopData
        self.sleepData = CDDataProvider.shared.sleepData
        self.moodData = CDDataProvider.shared.moodData
        self.energyData = CDDataProvider.shared.energyData
        displayPartnerData()
        
        CDNotificationManager.shared.requestNotificationAuthorization()
        CDNotificationManager.shared.scheduleDailyNotification(userName: CDDataProvider.shared.name)


        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePairingDismissed), name: NSNotification.Name("CDPairingDismissed"), object: nil)
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { notificatio in
            print("Foreground")
            
            self.fetchAndDisplayPartnerData()
        }
        
        // Long press gesture setup
        if CDDataProvider.shared.partnerID == nil {
            
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let pairingVC = storyboard.instantiateViewController(withIdentifier: "PartnerCodeViewController") as! PartnerCodeViewController
                
                pairingVC.shouldShowCloseButton = true
                pairingVC.modalPresentationStyle = .fullScreen
                // Set the UITabBarController as the root view controller
                self.present(pairingVC, animated: true, completion: nil)
            })
            

            
        }
        
    }
    
    
    func requestNotification() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Permission granted: \(granted)")
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    @objc func handlePairingDismissed() {
        print("Pairing View Controller was dismissed")
        fetchAndDisplayPartnerData() // Call the method to update data or perform actions
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CDPairingDismissed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ((self.poopData == nil || self.sleepData == nil || self.energyData == nil || self.moodData == nil) && CDDataProvider.shared.partnerID != nil) {
            fetchAndDisplayPartnerData()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.becomeFirstResponder()
        messageListener.listenForMessages()
        requestNotification()
    }
    
    func fetchAndDisplayPartnerData() {
        
        self.poopData = CDDataProvider.shared.poopData
        self.sleepData = CDDataProvider.shared.sleepData
        self.moodData = CDDataProvider.shared.moodData
        self.energyData = CDDataProvider.shared.energyData


        self.displayPartnerData() // Ensure that data gets displayed
        
        
        CDDataProvider.shared.loadMyDataAndThenPartnerData { success, userNeedMoreData, userData, partnerData, errorInfo in
            if success {
                
                DispatchQueue.main.async {
                    self.poopData = CDDataProvider.shared.poopData
                    self.sleepData = CDDataProvider.shared.sleepData
                    self.moodData = CDDataProvider.shared.moodData
                    self.energyData = CDDataProvider.shared.energyData

                    self.displayPartnerData() // Ensure that data gets displayed
                }
            }
        }
        
        
    }
    
    
    func displayPartnerData() {
        if let poopData = poopData {
            cardData[0].data = poopData
        } else {
            cardData[0].data = ["status": "No news today!"]
        }
        
        if let sleepData = sleepData {
            cardData[1].data = sleepData
        } else {
            cardData[1].data = ["status": "No sleep data yet"]
        }
        
        if let moodData = moodData {
            cardData[2].data = moodData
        } else {
            cardData[2].data = ["status": "No mood data yet"]
        }
        
        
        if let energyData = energyData {
            cardData[3].data = energyData
        } else {
            cardData[3].data = ["status": "No energy data yet"]
        }
        
        self.collectionView.reloadData()
    }
    
    private func setupUI() {
        // Configure greetingLabel (same logic as before)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.adjustsFontSizeToFitWidth = true
        greetingLabel.minimumScaleFactor = 0.5
        greetingLabel.lineBreakMode = .byClipping
        greetingLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        greetingLabel.textColor = .black
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        var greetingText = "Hello"
        if let userName = CDDataProvider.shared.name {
            let capitalizedUserName = userName.capitalizeFirstLetters()
            greetingText = currentHour < 12 ? "Good Morning, \(capitalizedUserName)" : currentHour < 18 ? "Good Afternoon, \(userName)" : "Good Evening, \(userName)"
        } else {
            greetingText = "Hello!"
        }
        greetingLabel.text = greetingText
        view.addSubview(greetingLabel)
        
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
 
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        
        // Set estimated item size to automatic size to allow dynamic height
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 16 // Add vertical spacing between cells
        
        // Set the layout to only allow one cell per row (full width)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PartnerActivityCardCell.self, forCellWithReuseIdentifier: "PartnerActivityCardCell")
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .CDBackground
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }







    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PartnerActivityCardCell", for: indexPath) as! PartnerActivityCardCell
        let data = cardData[indexPath.item]
        cell.configure(withTitle: data.title, animationName: data.animationName, recordData: data.data,backgroundColour: data.BackgroundColour)
        return cell
    }
}



// MARK: - Custom UICollectionViewCell for Cards

class PartnerActivityCardCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private var animationView: LottieAnimationView?
    private let statusStackView = UIStackView()
    private let bgView = UIView() // Same background view as CDCareViewController
    
    private let horizontalPadding: CGFloat = 25
    private let verticalPadding: CGFloat = 20
    private let lottieSize: CGFloat = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configure the cell for each specific case
    func configure(withTitle title: String, animationName: String?, recordData: [String: Any]?,backgroundColour : UIColor =  UIColor.white) {
        titleLabel.text = title
        
        // Background color and corner radius
        bgView.backgroundColor = backgroundColour // Adjust the background color based on your design
        bgView.layer.cornerRadius = 18
        
        if title == "Vibe Check", let animationName = animationName {
            // Display multiple animations for Vibe Check
            displayAnimations(animationName: animationName, recordData: recordData)
        } else {
            // Display single status for other cards
            displayStatus(recordData)
        }

        // Set up the main animation view for all cells
        if let animationName = animationName {
            animationView?.animation = LottieAnimation.named(animationName)
            animationView?.isHidden = false
            animationView?.play()
        } else {
            animationView?.isHidden = true
        }
    }
    
    // Setup views and layout (same as CDCareViewController)
    private func setupCardUI() {
        // Configure the background view (bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        // Configure titleLabel
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(titleLabel)
        
        // Configure statusLabel
        statusLabel.font = UIFont(name: "Poppins-Regular", size: 18)
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(statusLabel)

        // Configure statusStackView for multiple items
        statusStackView.axis = .vertical
        statusStackView.spacing = 8
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(statusStackView)
        
        // Configure animationView (for cards with animations)
        animationView = LottieAnimationView()
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.isHidden = true
        bgView.addSubview(animationView!)

        // Add constraints to bgView to enforce width and layout
        NSLayoutConstraint.activate([
            bgView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 40), // Adjust for insets
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Constraints for titleLabel, statusLabel, animationView, and statusStackView
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: bgView.trailingAnchor, constant: -horizontalPadding),
            
            animationView!.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20),
            animationView!.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -horizontalPadding),
            animationView!.widthAnchor.constraint(equalToConstant: lottieSize),
            animationView!.heightAnchor.constraint(equalToConstant: lottieSize),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 50),
            statusLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: horizontalPadding),
            statusLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -horizontalPadding),
            
            statusStackView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            statusStackView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: horizontalPadding),
            statusStackView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -horizontalPadding),
            statusStackView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -verticalPadding)
        ])
    }
    
    // Function to display single status (for Number Two News, Sleep, Energy)
    private func displayStatus(_ recordData: [String: Any]?) {
        // Reset stack view for new data
        statusStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Get status from the array (show the first item or default)
        if let statuses = recordData?["status"] as? [String], let firstStatus = statuses.first {
            statusLabel.isHidden = false
            statusLabel.text = firstStatus
           // statusStackView.isHidden = true
        } else {
            statusLabel.text = "No Update"
            statusLabel.isHidden = false

           // statusStackView.isHidden = true
        }
    }
    
    // Function to display animations for Vibe Check (with mood-specific animations)
    private func displayAnimations(animationName: String, recordData: [String: Any]?) {
        // Reset stack view for new data
        statusStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        statusLabel.isHidden = true
        statusStackView.isHidden = false
        
        // Display multiple small animations based on mood statuses (e.g., [Sad, Happy])
        if let statuses = recordData?["status"] as? [String], !statuses.isEmpty {
            for mood in statuses {
                // Create a Lottie animation view using the mood name as the animation
                let smallAnimationView = LottieAnimationView(name: mood)
                smallAnimationView.contentMode = .scaleAspectFit
                smallAnimationView.loopMode = .loop
                smallAnimationView.translatesAutoresizingMaskIntoConstraints = false
                smallAnimationView.widthAnchor.constraint(equalToConstant: 35).isActive = true
                smallAnimationView.heightAnchor.constraint(equalToConstant: 35).isActive = true
                smallAnimationView.play()
                
                // Create a label for the mood
                let statusItemLabel = UILabel()
                statusItemLabel.text = mood
                statusItemLabel.font = UIFont(name: "Poppins-Light", size: 16)
                statusItemLabel.textColor = .CDText
                
                // Combine animation and label in a stack view
                let stackView = UIStackView(arrangedSubviews: [smallAnimationView, statusItemLabel])
                stackView.axis = .horizontal
                stackView.spacing = 8
                stackView.alignment = .center
                
                statusStackView.addArrangedSubview(stackView)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        animationView?.stop()
        animationView?.isHidden = true
        statusStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear views
    }
    
    
}







