//
//  PersonDataModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation

struct Person: Codable {
    let personID: String
    var fullName: String
    var phoneNumber: String?
    var imageURL: String?
    let createdAt: Date
    var updatedAt: Date
    
    init(personID: String = UUID().uuidString,
         fullName: String,
         phoneNumber: String?,
         imageURL: String?,
         createdDate: Date = Date()) {
        self.personID = personID
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        self.createdAt = createdDate
        self.updatedAt = createdDate
    }
}
