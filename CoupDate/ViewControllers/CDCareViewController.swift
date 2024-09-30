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
        cardItems = [CardModel(title: "Your Insight", text: CDDataProvider.shared.smart_Insight?["My_Insight"]! ?? "No data for your mood, energy, or sleep today. Check back later.", backgroundColor: .cdInsightBackground1, animationName: "Woman"),
                     CardModel(title: "Your Partner", text: CDDataProvider.shared.smart_Insight?["Partner_Insight"]! ?? "No data for your partner today. Encourage tracking", backgroundColor: .cdInsightBackground2, animationName: "Sleeping"),
                     CardModel(title: "Relationship", text: CDDataProvider.shared.smart_Insight?["Relationship_Insight"]! ?? "Not enough data to provide relationship insights today.", backgroundColor: .cdInsightBackground3, animationName: "Woman")]
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize  = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
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





class CardCollectionViewCell: UICollectionViewCell {

    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private var animationView: LottieAnimationView?
    private let bgView = UIView() // Add a background view

    private let horizontalPadding: CGFloat = 25
    private let verticalPadding: CGFloat = 20
    private let lottieSize: CGFloat = 100

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Configure the bgView
        bgView.layer.cornerRadius = 18
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)

        // Title label setup
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(titleLabel)

        // Text label setup for dynamic height
        textLabel.font = UIFont(name: "Poppins-Regular", size: 18)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(textLabel)

        // Lottie animation view setup
        animationView = LottieAnimationView()
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        animationView?.isHidden = true
        if let animationView = animationView {
            bgView.addSubview(animationView)
        }

        // Add bgView constraints to enforce a fixed width
        NSLayoutConstraint.activate([
            // Set bgView to have a fixed width with screen size minus insets
            bgView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 30), // Adjust for insets
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Apply constraints to titleLabel, textLabel, and animationView within bgView
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: animationView!.leadingAnchor, constant: -horizontalPadding),

            animationView!.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalPadding),
            animationView!.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -horizontalPadding),
            animationView!.widthAnchor.constraint(equalToConstant: lottieSize),
            animationView!.heightAnchor.constraint(equalToConstant: lottieSize),

            textLabel.topAnchor.constraint(equalTo: animationView!.bottomAnchor, constant: 16),
            textLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: horizontalPadding),
            textLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -horizontalPadding),
            textLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -verticalPadding)
        ])
    }

    // Configure the cell with dynamic content and optional animation
    func configure(with model: CardModel) {
        titleLabel.text = model.title
        bgView.backgroundColor = model.backgroundColor
        displayText(model.text)

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
    }
}







