import UIKit
import Lottie

class DataEntryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let greetingLabel = UILabel()
    
    var collectionView: UICollectionView!
    
    // Example Data for Cards (This can be dynamic)
    let cardData: [(title: String, animationName: String)] = [
        ("Poop Status", "Poop"),
        ("Sleep Status", "Sleeping"),
        ("Mood Check", "Mood")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
        // Configure the greetingLabel (same as in PartnerActivityViewController)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.adjustsFontForContentSizeCategory = false
        greetingLabel.lineBreakMode = .byClipping
        greetingLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        greetingLabel.textColor = .white
        
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        var greetingText = "Hello"
        if let userName = CDDataProvider.shared.name {
            if currentHour < 12 {
                greetingText = "\(userName), time for a quick update!"
            } else if currentHour < 18 {
                greetingText = "\(userName), time for a quick update!"
            } else {
                greetingText = "\(userName), time for a quick update!"
            }
        } else {
            greetingText = "Hello!"
        }
        greetingLabel.text = greetingText
        
        // Add greetingLabel to the main view
        view.addSubview(greetingLabel)
        
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 180) // Same size as PartnerActivityViewController cards
        layout.minimumLineSpacing = 16

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DataEntryCardCell.self, forCellWithReuseIdentifier: "DataEntryCardCell")

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),  // Add padding
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),  // Add padding
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataEntryCardCell", for: indexPath) as! DataEntryCardCell
        let data = cardData[indexPath.item]
        cell.configure(withTitle: data.title, animationName: data.animationName)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Present a new view controller based on the card tapped
//        let selectedCard = cardData[indexPath.item]
        print(indexPath.row)
        let layout = UICollectionViewFlowLayout()
        let vibeCheckVC = DynamicOptionsCollectionViewController(collectionViewLayout: layout)
        
        
        switch indexPath.row {
        case 0:
            print("Poop")
            
            vibeCheckVC.categoryTitle = "Poop Check"
            vibeCheckVC.descriptionText = "Did you poop today?"
            vibeCheckVC.options = ["Yes 😁", "No, I couldn't 😫", "Almost"]
            vibeCheckVC.lottieAnimations = [nil, nil, nil] // No animations
            vibeCheckVC.category = "poop"
        case 1:
            
            vibeCheckVC.categoryTitle = "Sleep Check"
            vibeCheckVC.descriptionText = "How was your sleep last night?"
            vibeCheckVC.options = ["Rested", "Tired", "Woke Up Often", "Deep Sleep", "Insomnia", "Overslept"]
            vibeCheckVC.lottieAnimations = [nil, nil, nil, nil, nil, nil] // No animations
            vibeCheckVC.category = "sleep"

            break
            
        case 2:
            
            vibeCheckVC.categoryTitle = "Vibe Check"
            vibeCheckVC.descriptionText = "How are you feeling today?"
            vibeCheckVC.options = ["Happy", "Excited","Loved", "Calm", "Stressed", "Anxious"]
            vibeCheckVC.lottieAnimations = ["Happy", "Excited","Loved", "Calm","Stressed","Anxious"] // Matching the options count
            vibeCheckVC.category = "mood"

            
            break
            
            
        default:
            return
        }

        vibeCheckVC.modalPresentationStyle = .fullScreen
        
        self.present(vibeCheckVC, animated: true, completion: nil)

    }
}

// MARK: - Custom UICollectionViewCell for Cards

class DataEntryCardCell: UICollectionViewCell {
    
    let animationView = LottieAnimationView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCardUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animationView)
        
        titleLabel.font = UIFont(name: "Poppins-Regular", size: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            animationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            animationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            animationView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(withTitle title: String, animationName: String) {
        titleLabel.text = title
        animationView.animation = LottieAnimation.named(animationName)
        animationView.play()
    }
}
