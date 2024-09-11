//
//  TripperButton.swift
//  Tripper
//
//  Created by Mohamad Farhand on 2023-07-16.
//

import Foundation
import UIKit

// 1
class CDButton: UIButton {
    // 2
    enum ButtonState {
        case normal
        case disabled
    }
    // 3
    private var disabledBackgroundColor: UIColor?
    private var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    
    // 4. change background color on isEnabled value changed
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                if let color = defaultBackgroundColor {
                    self.backgroundColor = UIColor(named: "CDAccent")
                }
            }
            else {
                if let color = disabledBackgroundColor {
                    self.backgroundColor = .gray
                }
            }
        }
    }
    
    // 5. our custom functions to set color for different state
    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .normal:
            defaultBackgroundColor = color
        }
    }
}
