//
//  UIImageExtension.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/6/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(imageURL: String?, placeholder: UIImage? = UIImage(named: "mock-profile")) {
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            self.kf.setImage(with: url, placeholder: placeholder)
        } else {
            self.image = placeholder
        }
    }
}
