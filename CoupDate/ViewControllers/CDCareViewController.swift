import UIKit
import Lottie

// Model to represent each card/item
struct CardModel {
    let title: String
    let text: String
    let backgroundColor: UIColor
    let animationName: String?
}


class CDCareViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var cardItems: [CardModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Insight"
        self.view.backgroundColor = .white
        setupNavigationBarAppearance()
        setupCollectionView()
        loadCardData() // Load data and reload collection view
    }
    
    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        if #available(iOS 15.0, *) {
            let scrollEdgeAppearance = UINavigationBarAppearance()
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.backgroundColor = UIColor.white
            
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.configureWithOpaqueBackground()
            standardAppearance.backgroundColor = .white
            
            navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
            navigationController?.navigationBar.standardAppearance = standardAppearance
        }
    }
    
    private func loadCardData() {
        cardItems = [CardModel(title: "Mood Insight", text: "You're feeling Happy and Grateful today!You're feeling Happy and Grateful today!You're feeling Happy and Grateful today!You're feeling Happy and Grateful today!You're feeling Happy and Grateful today!You're feeling Happy and Grateful today!You're feeling Happy and Grateful today!You're feeling Happy and Grateful today! QWERTY", backgroundColor: .systemPink, animationName: "Woman"),
                     CardModel(title: "Sleep Insight", text: "You had a good night's sleep You had a good night's sleep You had a good night's sleepYou had a good night's sleep  You had a good night's sleep You had a good night's sleep You had a good night's sleep... JESUS!!!", backgroundColor: .cdAccent, animationName: "Sleeping"),
             CardModel(title: "Exercise Insight", text: "You completed your workout routine today. Keep going!... You completed your workout routine today. Keep going! You completed your workout routine today. Keep going! You completed your workout routine today. Keep going! You completed your workout routine today. Keep going! MONICA!!!!!! ", backgroundColor: .green, animationName: "Woman")]
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize  = CGSize(width: 350, height: 300) // Enable dynamic cell sizing
        layout.minimumLineSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: "CardCell")
        view.addSubview(collectionView)
        
        // Apply Auto Layout constraints for the collection view
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
            
        ])
    }
}



extension CDCareViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCollectionViewCell else {
            fatalError("Unable to dequeue CardCollectionViewCell")
        }
        
        let model = cardItems[indexPath.item]
        cell.configure(with: model)
        return cell
    }
}


import UIKit
import Lottie

class CardCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private var animationView: LottieAnimationView? // Lottie animation view
    
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 8
    private let lottieSize: CGFloat = 100 // Size for the Lottie animation view
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        // Apply corner radius to contentView
        contentView.layer.cornerRadius = 12 // Adjust the corner radius as needed
        contentView.layer.masksToBounds = true
        // Title label setup
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Text label setup for dynamic height
        textLabel.font = UIFont(name: "Poppins-Regular", size: 16)
        textLabel.numberOfLines = 0 // Allows the label to expand vertically
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        
        // Lottie animation view setup
        animationView = LottieAnimationView()
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.isHidden = true // Initially hidden, only shown if animation is provided
        if let animationView = animationView {
            contentView.addSubview(animationView)
        }
        
        // Apply constraints to titleLabel, textLabel, and animationView
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: animationView!.leadingAnchor, constant: -horizontalPadding),
            
            // Text label constraints
            textLabel.topAnchor.constraint(equalTo: animationView!.bottomAnchor, constant: verticalPadding),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding),
            
            // Lottie animation view constraints (Top-right corner of the title)
            animationView!.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            animationView!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            animationView!.widthAnchor.constraint(equalToConstant: lottieSize),
            animationView!.heightAnchor.constraint(equalToConstant: lottieSize)
        ])
    }
    
    // Configure the cell with dynamic content and optional animation
    func configure(with model: CardModel) {
        titleLabel.text = model.title
        contentView.backgroundColor = model.backgroundColor
        displayText(model.text)
        
        // Configure the Lottie animation if present
        if let animationName = model.animationName {
            animationView?.animation = LottieAnimation.named(animationName)
            animationView?.isHidden = false
            animationView?.play()
        } else {
            animationView?.isHidden = true
        }
    }
    
    // Set attributed text for the textLabel
    private func displayText(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let mainFont = UIFont(name: "Poppins-Regular", size: 16)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: mainFont!,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        textLabel.attributedText = attributedString
        
        // Set preferredMaxLayoutWidth to ensure wrapping
        textLabel.preferredMaxLayoutWidth = contentView.frame.width - (horizontalPadding)
    }
    
    // Override layoutSubviews to make sure preferredMaxLayoutWidth is updated when layout changes
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.preferredMaxLayoutWidth = contentView.frame.width - (horizontalPadding)
    }
}






