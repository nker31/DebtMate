//
//  DebtMateTextField.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import UIKit

class DebtMateTextField: UITextField {
    init(placeholder: String, type: TextFieldType = .text) {
        super.init(frame: .zero)
        
        self.backgroundColor = .textfield
        self.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor(named: "textfieldPlaceholder"),
                    .font: UIFont.systemFont(ofSize: 16)
                ]
        )
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.setLeftPaddingPoints(12)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        switch type {
        case .name, .text, .email:
            self.autocorrectionType = .no
            self.autocapitalizationType = .none
        case .password:
            isSecureTextEntry = true
        case .phoneNumber:
            self.keyboardType = .phonePad
        case .number:
            self.keyboardType = .decimalPad
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
}

