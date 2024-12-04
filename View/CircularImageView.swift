//
//  CircularImageView.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit

class CircularImageView: UIImageView {

    init(cornerRadius: CGFloat = 0) {
        super.init(frame: .zero)
        self.contentMode = .scaleAspectFill
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        self.layer.borderColor = UIColor.separator.cgColor
        self.layer.borderWidth = 0.5
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
}
