//
//  EmptyStateLabel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import UIKit

class EmptyStateLabel: UILabel {

    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.textAlignment = .center
        self.textColor = .secondaryLabel
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
}
