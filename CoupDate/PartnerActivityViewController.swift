import UIKit
import Lottie
import Combine
import Firebase

class PartnerActivityViewController: UIViewController {
    
    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let poopCardView = UIView()
    let poopStatusLabel = UILabel()
//    let /*poopDetailLabel*/ = UILabel()
    let poopAnimationView = LottieAnimationView(name: "Poop") // Replace with your poop animation name
    
    let sleepCardView = UIView()
    let sleepStatusLabel = UILabel()
    let sleepDetailLabel = UILabel()
    let sleepAnimationView = LottieAnimationView(name: "Sleeping") // Replace with your sleep animation name
    
    var poopData: [String: Any]?
    var sleepData: [String: Any]?
    
    private var viewModel = PartnerViewModel()
    private var cancellables = Set<AnyCancellable>()


    
  //  let dataEntryImageView = UIImageView()
    
    // Detect shake gesture
       override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
           if motion == .motionShake {
               generateAndShareInvitationURL()
           }
       }
    
    
    
    func generateInvitationLink(partnerUserId: String) -> URL? {
        // Define the base URL using your custom URL scheme
        let baseURL = "coupdate://pair"
        
        // Create the URL components
        var components = URLComponents(string: baseURL)
        
        // Add query parameters
        components?.queryItems = [
            URLQueryItem(name: "partnerUserId", value: partnerUserId)
        ]
        
        // Return the complete URL
        return components?.url
    }
    
    
    func generateInvitationURL() -> URL? {
         // Replace this with your logic to generate the user's unique invitation URL
         guard let userId = Auth.auth().currentUser?.uid else {
             print("User is not logged in.")
             return nil
         }
         
         // Example URL creation (use your domain and path)
         let invitationLink = "https://mytripper.app/pair?partnerUserId=\(userId)"
         return URL(string: invitationLink)
     }
     
     func generateAndShareInvitationURL() {
         
         guard let invitationURL = generateInvitationLink(partnerUserId: UserManager.shared.currentUserID ?? "") else { return }

         // Present the activity controller
         let activityVC = UIActivityViewController(activityItems: [invitationURL], applicationActivities: nil)
         present(activityVC, animated: true)
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        displayPartnerData()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { notification in
            print("Foreground")
            
            self.fetchPartnerData()
        }
        
        if self.poopData == nil || self.sleepData == nil {
            fetchPartnerData()
        }
        

    }
    
    func fetchPartnerData() {
        
        // Bind to the ViewModel's isLoading and errorMessage
        self.viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    // Show loading indicator
                } else {
                    // Hide loading indicator
                }
            }
            .store(in: &self.cancellables)
        
        self.viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    // Show error message
                    print(errorMessage)
                }
            }
            .store(in: &self.cancellables)
        
        self.viewModel.$poopData
            .combineLatest(self.viewModel.$sleepData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] poopData, sleepData in
                guard let self = self else { return }
                
                // Add a delay of 3 seconds before transitioning to PartnerActivityViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {


                    self.poopData = poopData
                    self.sleepData = sleepData
                    self.displayPartnerData()

                }
            }
            .store(in: &self.cancellables)
        if let partnerID = CDDataProvider.shared.partnerID {
            self.viewModel.loadPartnerData(partnerID: partnerID)
        }
        
    }
    
    func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Configure Card Views
        configureCardView(poopCardView, withLabels: [poopStatusLabel], animationView: poopAnimationView)
        configureCardView(sleepCardView, withLabels: [sleepStatusLabel, sleepDetailLabel], animationView: sleepAnimationView)
        
        // Layout using UIStackView for cards
        let stackView = UIStackView(arrangedSubviews: [poopCardView, sleepCardView])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        // Set up stack view constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120) // Adjusted to leave space for the dataEntryImageView
        ])
        
        NSLayoutConstraint.activate([
            poopCardView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40),
            poopCardView.heightAnchor.constraint(equalToConstant: 180), // Adjusted height for animation and labels
            
            sleepCardView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40),
            sleepCardView.heightAnchor.constraint(equalToConstant: 180) // Adjusted height for animation and labels
        ])
    }


    
    func configureCardView(_ cardView: UIView, withLabels labels: [UILabel], animationView: LottieAnimationView?) {
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
        
        // Configure Animation View
        if let animationView = animationView {
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
            animationView.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(animationView)
            
            NSLayoutConstraint.activate([
                animationView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
                animationView.topAnchor.constraint(equalTo: cardView.topAnchor),
                animationView.heightAnchor.constraint(equalToConstant: 100) // Set height for animation to give space for labels
            ])
        }
        
        // Configure Stack View for Labels
        let cardStackView = UIStackView(arrangedSubviews: labels)
        cardStackView.axis = .vertical
        cardStackView.spacing = 8
        cardStackView.alignment = .leading
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(cardStackView)
        
        NSLayoutConstraint.activate([
            cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStackView.topAnchor.constraint(equalTo: animationView?.bottomAnchor ?? cardView.topAnchor, constant: 8),
            cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
        
        for label in labels {
            label.numberOfLines = 0
            label.textAlignment = .left
            label.adjustsFontForContentSizeCategory = true
            label.backgroundColor = .clear
        }
        
        poopStatusLabel.font = UIFont(name:"Poppins-Regular", size: 18)
        poopStatusLabel.textColor = .label
        
//        poopDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
//        poopDetailLabel.textColor = .secondaryLabel
        
        sleepStatusLabel.font = UIFont(name:"Poppins-Regular", size: 18)
        sleepStatusLabel.textColor = .label
        
        sleepDetailLabel.font = UIFont(name:"Poppins-Light", size: 15)
        sleepDetailLabel.textColor = .secondaryLabel
    }

    
    @objc func openDataEntry() {
        let dataEntryVC = DataEntryViewController()
        let moodSelectionViewController = MoodSelectionViewController()
        self.present(moodSelectionViewController, animated: true)
    }
    
    func displayPartnerData() {
        if let poopData = poopData {
            poopStatusLabel.text = "Your partner's 💩 Status Today: \(poopData["status"] as? String ?? "No 💩 Data found")"
           // poopDetailLabel.text = poopData["details"] as? String ?? ""
        }
        
        if let sleepData = sleepData {
            sleepStatusLabel.text = "Your partner's 😴 status: \(sleepData["status"] as? String ?? "No 😴 Data found")"
            sleepDetailLabel.text = sleepData["details"] as? String ?? ""
        }
    }
}
