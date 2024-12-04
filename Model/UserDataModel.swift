//
//  UserDataModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation

struct User: Codable {
    let userID: String
    var fullName: String
    let email: String
    var imageURL: String?
    let createdAt: Date
    let lastLogin: Date
    
    init(userId: String, fullName: String, email: String, imageURL: String?, createdAt: Date, lastLogin: Date) {
        self.userID = userId
        self.fullName = fullName
        self.email = email
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.lastLogin = lastLogin
    }
}
