//
//  TransactionError.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/12/24.
//

import Foundation

enum TransactionError: LocalizedError {
    case dataStoringFailed
    case fetchDataFailed
    case decodingFailed
    case dataEditingFailed
    case dataDeletionFailed
    case unknownError

    var errorDescription: String? {
        switch self {
        case .dataStoringFailed:
            return "Unable to save the transaction. Please try again."
        case .fetchDataFailed:
            return "Unable to retrieve data. Please check your connection and try again."
        case .decodingFailed:
            return "Data could not be processed. Please report this issue."
        case .dataEditingFailed:
            return "Unable to edit the transaction. Please try again."
        case .dataDeletionFailed:
            return "Unable to delete the transaction. Please try again."
        case .unknownError:
            return "An unknown error occurred. Please try again later."
        }
    }
}
