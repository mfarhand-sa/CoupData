import UIKit
import Lottie

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
    
    let dataEntryImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "💑 Coudate"
        
        setupUI()
        displayPartnerData()
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
        
        configureDataEntryImageView() // Ensure this is called after adding to contentView
        
        // Place dataEntryImageView at the bottom of the screen
        view.addSubview(dataEntryImageView)
        NSLayoutConstraint.activate([
            dataEntryImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), // Anchored to the bottom of the screen
            dataEntryImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dataEntryImageView.widthAnchor.constraint(equalToConstant: 100),
            dataEntryImageView.heightAnchor.constraint(equalToConstant: 100)
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
        
        poopStatusLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        poopStatusLabel.textColor = .label
        
//        poopDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
//        poopDetailLabel.textColor = .secondaryLabel
        
        sleepStatusLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        sleepStatusLabel.textColor = .label
        
        sleepDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        sleepDetailLabel.textColor = .secondaryLabel
    }
    
    func configureDataEntryImageView() {
        if let image = UIImage(named: "funny_couples") {
            dataEntryImageView.image = image
        } else {
            print("Image not found!")
        }
        
        dataEntryImageView.contentMode = .scaleAspectFit
        dataEntryImageView.isUserInteractionEnabled = true
        dataEntryImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDataEntry)))
        dataEntryImageView.isHidden = false
        dataEntryImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func openDataEntry() {
        let dataEntryVC = DataEntryViewController()
        self.present(dataEntryVC, animated: true)
    }
    
    func displayPartnerData() {
        if let poopData = poopData {
            poopStatusLabel.text = "Mo's 💩 Status Today: \(poopData["status"] as? String ?? "No 💩 Data found")"
           // poopDetailLabel.text = poopData["details"] as? String ?? ""
        }
        
        if let sleepData = sleepData {
            sleepStatusLabel.text = "Mo's 😴 status: \(sleepData["status"] as? String ?? "No 😴 Data found")"
            sleepDetailLabel.text = sleepData["details"] as? String ?? ""
        }
    }
}
