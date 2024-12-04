//
//  DebtMateButton.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import UIKit

enum buttonType {
    case regular
    case subButton
}

class DebtMateButton: UIButton {
    init(title: String, type: buttonType = .regular) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case .regular:
            self.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            self.setTitleColor(.debtMateWhite, for: .normal)
            self.backgroundColor = .debtMateBlack
            self.layer.cornerRadius = 8
            self.clipsToBounds = true
        case .subButton:
            self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            self.setTitleColor(.debtMateBlack, for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
}
