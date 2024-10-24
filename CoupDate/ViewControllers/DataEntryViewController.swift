import UIKit
import Lottie

class DataEntryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let greetingLabel = UILabel()
    
    var collectionView: UICollectionView!
    
    // Example Data for Cards (This can be dynamic)
    
    var cardData: [(title: String, animationName: String, BackgroundColour: UIColor)] = [
        ("Number Two News", "Poop", .cdInsightBackground1),
        ("Sleep Tracker", "Sleeping",.cdInsightBackground2),
        ("Vibe Check", "Mood",.cdInsightBackground4),
        ("Energy Meter", "Energy",.cdInsightBackground3),
        ("My Thoughts", "Thoughts",.cdInsightBackground1)

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .CDBackground //UIColor(named: "CDBackground")
        
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
        // Configure the greetingLabel (same as in PartnerActivityViewController)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.adjustsFontSizeToFitWidth = true
        greetingLabel.minimumScaleFactor = 0.5
        greetingLabel.lineBreakMode = .byClipping
        greetingLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        greetingLabel.textColor = .black
        self.view.backgroundColor = .CDBackground //UIColor(named: "CDBackground")
        self.scrollView.backgroundColor = .CDBackground  //UIColor(named: "CDBackground")
        
        
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
        collectionView.backgroundColor = .CDBackground //UIColor(named: "CDBackground")
        collectionView.showsVerticalScrollIndicator = false
        // Add contentInset to ensure enough space for scrolling past the last cell
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        // Also adjust the scroll indicators to match the content inset
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

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
        cell.configure(withTitle: data.title, animationName: data.animationName,backgrounColour:data.BackgroundColour)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Present a new view controller based on the card tapped
//        let selectedCard = cardData[indexPath.item]
        print(indexPath.row)
        Haptic.play()

        let layout = UICollectionViewFlowLayout()
        let vibeCheckVC = DynamicOptionsCollectionViewController(collectionViewLayout: layout)
        
        
        switch indexPath.row {
        case 0:
            print("Poop")
            
            vibeCheckVC.categoryTitle = "Poop Check"
            vibeCheckVC.descriptionText = "Did you poop today?"
            vibeCheckVC.options = ["Yes 😁", "No, I couldn't 😫", "Almost"]
//            vibeCheckVC.lottieAnimations = [nil, nil, nil] // No animations
            vibeCheckVC.category = "poop"
        case 1:
            
            vibeCheckVC.categoryTitle = "Sleep Check"
            vibeCheckVC.descriptionText = "How was your sleep last night?"
            vibeCheckVC.options = [
                "Rested 😌",         // Feeling refreshed after sleep
                "Tired 😴",          // Feeling tired even after sleep
                "Woke Up Often 😟",  // Frequent waking during the night (same as Interrupted)
                "Deep Sleep 🛏️",    // Experienced restorative deep sleep
                "Short Sleep 💤",    // Mostly light, non-restorative sleep
                "Insomnia 💤",       // Difficulty falling or staying asleep
                "Overslept 😫"       // Slept longer than planned or needed
            ]
//            vibeCheckVC.lottieAnimations = [nil, nil, nil, nil, nil, nil] // No animations
            vibeCheckVC.category = "sleep"

            break
            
        case 2:
            
            vibeCheckVC.categoryTitle = "Vibe Check"
            vibeCheckVC.descriptionText = "How are you feeling today?"
            vibeCheckVC.options = CDDataProvider.shared.moods ?? []
            vibeCheckVC.category = "mood"
            break
            
        case 3:
            
            vibeCheckVC.categoryTitle = "Energy Level Check"
            vibeCheckVC.descriptionText = "How's your energy level today?"
            vibeCheckVC.options = ["Drained 🪫", "Tired 😓", "Fine 😌", "Energized 💥", "Hyper 🔥"]
            vibeCheckVC.category = "energy"
            break
            
        case 4:
            
            
            let vc  = ThoughtViewController()
            vc.modalPresentationStyle = .fullScreen            
            self.present(vc, animated: true, completion: nil)

            return
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
        contentView.backgroundColor = .CDBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.layer.shadowColor = UIColor.white.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(animationView)
        
        titleLabel.font = UIFont(name: "Poppins-Regular", size: 18)
        titleLabel.textColor = .CDText
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
    
    func configure(withTitle title: String, animationName: String,backgrounColour: UIColor) {
        titleLabel.text = title
        animationView.animation = LottieAnimation.named(animationName)
        self.contentView.backgroundColor = backgrounColour
        animationView.play()
    }
}
