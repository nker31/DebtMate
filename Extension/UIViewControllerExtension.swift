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
    
    func setRootViewController(_ rootViewController: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()

            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
