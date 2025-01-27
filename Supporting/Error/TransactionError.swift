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
            return String(localized: "transaction_data_storing_failed")
        case .fetchDataFailed:
            return String(localized: "transaction_fetch_data_failed")
        case .decodingFailed:
            return String(localized: "transaction_decoding_failed")
        case .dataEditingFailed:
            return String(localized: "transaction_data_editing_failed")
        case .dataDeletionFailed:
            return String(localized: "transaction_data_deletion_failed")
        case .unknownError:
            return String(localized: "transaction_unknown_error")
        }
    }
}
