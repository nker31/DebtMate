//
//  ContactDataModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import Foundation

import UIKit

struct Contact {
    let name: String
    let phoneNumber: String?
    let profileImage: UIImage?
    
    init(name: String, phoneNumber: String?, profileImage: UIImage?) {
        self.name = name
        self.phoneNumber = phoneNumber?.replacingOccurrences(of: "-", with: "")
        self.profileImage = profileImage
    }
}
