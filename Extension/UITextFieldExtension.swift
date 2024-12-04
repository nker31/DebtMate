//
//  UITextFieldExtension.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation
import UIKit

extension UITextField {
    enum TextFieldType {
        case name
        case email
        case phoneNumber
        case password
        case text
        case number
    }
    
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
