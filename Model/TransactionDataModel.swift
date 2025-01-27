//
//  TransactionDataModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation

struct Transaction: Codable, Equatable {
    let transactionID: String
    let personID: String
    var amount: Float
    var description: String?
    var dueDate: Date?
    var isLend: Bool
    var isPaid: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(transactionID: String = UUID().uuidString,
         personID: String,
         amount: Float,
         isLend: Bool,
         description: String? = nil,
         dueDate: Date? = nil,
         isPaid: Bool = false,
         createdDate: Date = Date()) {
        self.transactionID = transactionID
        self.personID = personID
        self.amount = amount
        self.description = description
        self.dueDate = dueDate
        self.isLend = isLend
        self.isPaid = isPaid
        self.createdAt = createdDate
        self.updatedAt = createdDate
    }
}
