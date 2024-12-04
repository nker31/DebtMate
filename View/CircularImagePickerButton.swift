//
//  CircularImagePickerButton.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import UIKit

class CircularImagePickerButton: UIButton {
    init(cornerRadius: CGFloat = 0) {
        super.init(frame: .zero)
        self.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        self.layer.cornerRadius = 15
        self.backgroundColor = .systemGray6
        self.tintColor = .debtMateBlack
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.separator.cgColor
        self.layer.borderWidth = 0.5
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
}

