import Foundation
import UIKit

class PartnerActivityViewController: UIViewController {
    
    // UI Components
    let poopCardView = UIView()
    let poopStatusLabel = UILabel()
    let poopDetailLabel = UILabel()
    
    let sleepCardView = UIView()
    let sleepStatusLabel = UILabel()
    let sleepDetailLabel = UILabel()
    
    let dataEntryImageView = UIImageView() // Updated from UIButton to UIImageView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "💑 Coudate"
        
        setupUI()
        loadPartnerData()
    }
    
    func setupUI() {
        // Configure Card Views
        configureCardView(poopCardView, withLabels: [poopStatusLabel, poopDetailLabel])
        configureCardView(sleepCardView, withLabels: [sleepStatusLabel, sleepDetailLabel])
        
        configureDataEntryImageView()
        
        // Layout using UIStackView for cards
        let stackView = UIStackView(arrangedSubviews: [poopCardView, sleepCardView])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(dataEntryImageView) // Add dataEntryImageView to the view
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Card size
            poopCardView.widthAnchor.constraint(equalToConstant: 340),
            poopCardView.heightAnchor.constraint(equalToConstant: 150),
            sleepCardView.widthAnchor.constraint(equalToConstant: 340),
            sleepCardView.heightAnchor.constraint(equalToConstant: 150),
            
            // Data Entry Image View constraints
            dataEntryImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataEntryImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataEntryImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            dataEntryImageView.heightAnchor.constraint(equalToConstant: 100) // Adjust height as needed
            
        ])
        
        view.layoutIfNeeded() // Ensure layout update
    }
    
    func configureCardView(_ cardView: UIView, withLabels labels: [UILabel]) {
        cardView.backgroundColor = .secondarySystemBackground // Light gray background for visibility
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.separator.cgColor // Border color for contrast
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 8
        cardView.layer.masksToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let cardStackView = UIStackView(arrangedSubviews: labels)
        cardStackView.axis = .vertical
        cardStackView.spacing = 8
        cardStackView.alignment = .leading
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(cardStackView)
        
        NSLayoutConstraint.activate([
            cardStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
        
        // Configure labels
        for label in labels {
            label.numberOfLines = 0
            label.textAlignment = .left
            label.adjustsFontForContentSizeCategory = true
        }
        
        poopStatusLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        poopStatusLabel.textColor = .label
        
        poopDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        poopDetailLabel.textColor = .secondaryLabel
        
        sleepStatusLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sleepStatusLabel.textColor = .label
        
        sleepDetailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
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
        dataEntryImageView.translatesAutoresizingMaskIntoConstraints = false // Ensure Auto Layout is used
    }
    
    @objc func openDataEntry() {
        let dataEntryVC = DataEntryViewController()
        self.present(dataEntryVC, animated: true)
    }
    
    func loadPartnerData() {
        let partnerUserId =  UserManager.shared.partnerUserID // Replace with actual partner user ID
        let currentDate = Date()
        
        FirebaseManager.shared.loadDailyRecord(for: partnerUserId, date: currentDate) { [weak self] result in
            switch result {
            case .success(let data):
                if let poopData = data["poop"] as? [String: Any] {
                    self?.poopStatusLabel.text = "Mo's 💩 Status Today: \(poopData["status"] as? String ?? "N/A")"
                    //self?.poopDetailLabel.text = poopData["details"] as? String ?? ""
                }
                
                if let sleepData = data["sleep"] as? [String: Any] {
                    self?.sleepStatusLabel.text = "Mo's 😴: \(sleepData["status"] as? String ?? "N/A")"
                    self?.sleepDetailLabel.text = sleepData["details"] as? String ?? ""
                }
                
            case .failure(let error):
                print("Error loading partner data: \(error)")
            }
        }
    }
}
