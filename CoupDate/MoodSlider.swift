import UIKit

class MoodSlider: UISlider {
    
    private let faceLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSlider()
    }
    
    private func setupSlider() {
        self.minimumValue = 0
        self.maximumValue = 10
        self.value = 5
        self.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        // Set the colors for the slider to match the design
        self.minimumTrackTintColor = UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0) // Purple shade
        self.maximumTrackTintColor = UIColor.systemGray
        self.thumbTintColor = UIColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0) // Purple shade
        
        // Configure the face layer
        faceLayer.fillColor = UIColor.clear.cgColor
        faceLayer.strokeColor = UIColor.label.cgColor  // Adaptive color to ensure visibility in both light and dark modes
        faceLayer.lineWidth = 2.0
        self.layer.addSublayer(faceLayer)
        
        // Initial drawing of the face
        drawFace()
    }
    
    @objc private func valueChanged() {
        drawFace()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw face whenever layout changes to ensure proper positioning
        drawFace()
    }
    
    private func drawFace() {
        let facePath = UIBezierPath()
        let centerX = self.bounds.midX  // Correctly calculate centerX based on slider's current bounds
        let centerY: CGFloat = -130  // Adjust to keep the face 130 points from the top safe area for extra space from slider
        let radius: CGFloat = 80.0  // Keep the face large

        // Draw the circle for the face
        facePath.addArc(withCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        // Draw eyes
        facePath.move(to: CGPoint(x: centerX - 20, y: centerY - 20))
        facePath.addArc(withCenter: CGPoint(x: centerX - 20, y: centerY - 20), radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        facePath.move(to: CGPoint(x: centerX + 20, y: centerY - 20))
        facePath.addArc(withCenter: CGPoint(x: centerX + 20, y: centerY - 20), radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        // Draw mouth based on slider value, invert the value for opposite behavior
        let moodValue = CGFloat(self.value)  // Cast slider value to CGFloat for calculations
        let smileOffset = (5.0 - moodValue) * 5.0  // Invert the slider effect for smiley to sad

        facePath.move(to: CGPoint(x: centerX - 20, y: centerY + 20 + smileOffset))
        facePath.addQuadCurve(to: CGPoint(x: centerX + 20, y: centerY + 20 + smileOffset), controlPoint: CGPoint(x: centerX, y: centerY + 40 - smileOffset))
        
        // Apply the path to the face layer
        faceLayer.path = facePath.cgPath
        
        // Ensure faceLayer frame matches the slider's bounds to prevent animation issues
        faceLayer.frame = self.bounds
    }
}
