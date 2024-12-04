//
//  UIViewControllerExtension.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation
import UIKit

extension UIViewController {
    func createTextFieldRow(title: String, field: UITextField) -> UIStackView {
        let label: UILabel = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .debtMateBlack
        
        let labelStackView = UIStackView(arrangedSubviews: [label, field])
        labelStackView.axis = .vertical
        labelStackView.spacing = 10
        
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelStackView
    }
}
