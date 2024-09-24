

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


class PartnerActivityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let greetingLabel = UILabel()
    
    var collectionView: UICollectionView!
    
//    public var viewModel : PartnerViewModel!
    
    let messageListener = MessageListener()
    
    // Example Data for Cards (This can be dynamic or fetched from a server)
    var cardData: [(title: String, animationName: String, data: [String: Any]?)] = [
        ("Poop Status", "Poop", nil),
        ("Sleep Status", "Sleeping", nil),
        ("Mood Check", "Mood", nil)
    ]
    
    var poopData: [String: Any]?
    var sleepData: [String: Any]?
    var moodData: [String: Any]?
    
    
    
    func updateWithData(poopData: [String: Any]?, sleepData: [String: Any]?, moodData: [String: Any]?) {
        self.poopData = poopData
        self.sleepData = sleepData
        self.moodData = moodData
        
        // Update the cardData array with the new data
        self.cardData[0].data = poopData
        self.cardData[1].data = sleepData
        self.cardData[2].data = moodData
        
        // Refresh the collection view
        self.collectionView.reloadData()
        displayPartnerData() // Ensure data is displayed correctly
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Now, the viewModel should be available here as it's passed from the LoadingViewController
//        if viewModel == nil {
//            fatalError("ViewModel is not initialized")
//        }
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupCollectionView()
        displayPartnerData()
        
        CDNotificationManager.shared.requestNotificationAuthorization()
        CDNotificationManager.shared.scheduleDailyNotification(userName: CDDataProvider.shared.name)


        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePairingDismissed), name: NSNotification.Name("CDPairingDismissed"), object: nil)
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { notificatio in
            print("Foreground")
            
            self.fetchAndDisplayPartnerData()
        }
        
        // Long press gesture setup
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 3.0
        self.view.addGestureRecognizer(longPressGesture)
        
        
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
    
    @objc func handlePairingDismissed() {
        print("Pairing View Controller was dismissed")
        fetchAndDisplayPartnerData() // Call the method to update data or perform actions
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CDPairingDismissed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ((self.poopData == nil || self.sleepData == nil) && CDDataProvider.shared.partnerID != nil) {
            fetchAndDisplayPartnerData()
        }
        

        
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.becomeFirstResponder()
        messageListener.listenForMessages()
        
//        FirebaseManager.shared.generateInsightsForAllUsers { result in
//            switch result {
//            case .success(let message):
//                print("Insights generated successfully: \(message)")
//            case .failure(let error):
//                print("Error generating insights: \(error.localizedDescription)")
//            }
//        }
        
        
    }
    
    func fetchAndDisplayPartnerData() {
        
        self.poopData = CDDataProvider.shared.poopData
        self.sleepData = CDDataProvider.shared.sleepData
        self.moodData = CDDataProvider.shared.moodData

        self.displayPartnerData() // Ensure that data gets displayed
        
        
        CDDataProvider.shared.loadMyDataAndThenPartnerData { success, userNeedMoreData, userData, partnerData, errorInfo in
            if success {
                
                DispatchQueue.main.async {
                    self.poopData = CDDataProvider.shared.poopData
                    self.sleepData = CDDataProvider.shared.sleepData
                    self.moodData = CDDataProvider.shared.moodData
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
        
        self.collectionView.reloadData()
    }
    
    private func setupUI() {
        // Configure greetingLabel (same logic as before)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.adjustsFontForContentSizeCategory = false
        greetingLabel.lineBreakMode = .byClipping
        greetingLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        greetingLabel.textColor = .accent
        
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
        
        // Set consistent padding (insets) for the entire section
        layout.sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)  // Padding for all sides (left, right, top, bottom)
        
        // Set minimum line spacing between cards
        layout.minimumLineSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PartnerActivityCardCell.self, forCellWithReuseIdentifier: "PartnerActivityCardCell")
        
        view.addSubview(collectionView)
        
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
        cell.configure(withTitle: data.title, animationName: data.animationName, recordData: data.data)
        return cell
    }
    
    // Handle Long Press Gesture
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("Long press began")
            let sb = UIStoryboard(name: "Main", bundle: .main)
            let pairingVC = sb.instantiateViewController(withIdentifier: "CDPairingViewController") as! CDPairingViewController
            pairingVC.mode = .invitation
            UIApplication.shared.keyWindow?.rootViewController?.present(pairingVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the width of each card to ensure consistent width
        let totalWidth = collectionView.bounds.width
        let padding: CGFloat = 40 // 20 on each side
        let availableWidth = totalWidth - padding
        
        // Dynamic height based on content but enforce a minimum height to prevent compactness
        let minHeight: CGFloat = 180 // Minimum height to avoid overly compact cards
        return CGSize(width: availableWidth, height: minHeight)
    }




}



// MARK: - Custom UICollectionViewCell for Cards

class PartnerActivityCardCell: UICollectionViewCell {
    
    let mainAnimationView = LottieAnimationView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let statusStackView = UIStackView() // Stack for multiple small animations and status labels
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withTitle title: String, animationName: String, recordData: [String: Any]?) {
        titleLabel.text = title
        mainAnimationView.animation = LottieAnimation.named(animationName)
        mainAnimationView.play()

        // Clear the stack before adding new items
        statusStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let data = recordData {
            if let statuses = data["status"] as? [String], !statuses.isEmpty {
                statusLabel.isHidden = true
                statusStackView.isHidden = false

                // Add small animations and status labels for each status
                for status in statuses {
                    let smallAnimationView = LottieAnimationView(name: status)
                    smallAnimationView.contentMode = .scaleAspectFit
                    smallAnimationView.loopMode = .loop
                    smallAnimationView.translatesAutoresizingMaskIntoConstraints = false
                    smallAnimationView.widthAnchor.constraint(equalToConstant: 35).isActive = true
                    smallAnimationView.heightAnchor.constraint(equalToConstant: 35).isActive = true
                    smallAnimationView.play()

                    let statusItemLabel = UILabel()
                    statusItemLabel.text = status
                    statusItemLabel.font = UIFont(name: "Poppins-Light", size: 16)
                    statusItemLabel.textColor = .CDText
                    statusItemLabel.numberOfLines = 1
                    statusItemLabel.lineBreakMode = .byTruncatingTail
                    statusItemLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

                    let stackView: UIStackView
                    
                    if title != "Mood Check" {
                        // Vertical stack for titles other than "Mood Check"
                        stackView = UIStackView(arrangedSubviews: [statusItemLabel])
                        stackView.axis = .vertical // Set to vertical to stack items on top of each other
                        stackView.spacing = 1 // Adjust spacing between the elements
                        stackView.alignment = .leading // Align both items to the left
                    } else {
                        // Horizontal stack for "Mood Check"
                        stackView = UIStackView(arrangedSubviews: [smallAnimationView, statusItemLabel])
                        stackView.axis = .horizontal // Horizontal layout for Mood Check
                        stackView.spacing = 8
                        stackView.alignment = .center

                    }
                    


                    statusStackView.addArrangedSubview(stackView)
                }
            } else {
                // Single status or no data
                statusStackView.isHidden = true
                statusLabel.isHidden = false
                statusLabel.text = data["status"] as? String ?? "Nothing shared yet!"
            }
        } else {
            statusLabel.isHidden = false
            statusLabel.text = "Nothing shared yet!"
            statusStackView.isHidden = true
        }
    }

    // Adjust layout in `setupCardUI`
    func setupCardUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false

        // Setup titleLabel
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 16)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Setup main animation view
        mainAnimationView.contentMode = .scaleAspectFit
        mainAnimationView.loopMode = .loop
        mainAnimationView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainAnimationView)

        // Setup status label and stack view
        statusLabel.font = UIFont(name: "Poppins-Light", size: 16)
        statusLabel.textColor = .CDText
        statusLabel.numberOfLines = 0 // Allow label to wrap
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)

        statusStackView.axis = .vertical // Display multiple statuses vertically
        statusStackView.spacing = 8
        statusStackView.alignment = .leading
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusStackView)

        // Set consistent padding and constraints inside each card (contentView)
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: mainAnimationView.leadingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),


            // Main animation view
            mainAnimationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainAnimationView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainAnimationView.widthAnchor.constraint(equalToConstant: 120),
            mainAnimationView.heightAnchor.constraint(equalToConstant: 120),

            // Status label
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            // Status stack view (used for multiple items)
            statusStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            statusStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            statusStackView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statusStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
