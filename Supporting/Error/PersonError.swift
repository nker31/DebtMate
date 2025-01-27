//
//  PersonError.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import Foundation

enum PersonError: LocalizedError {
    case dataStoringFailed
    case fetchDataFailed
    case decodingFailed
    case dataEditingFailed
    case dataDeletionFailed
    case unknownError

    var errorDescription: String? {
        switch self {
        case .dataStoringFailed:
            return String(localized: "person_data_storing_failed")
        case .fetchDataFailed:
            return String(localized: "person_fetch_data_failed")
        case .decodingFailed:
            return String(localized: "person_decoding_failed")
        case .dataEditingFailed:
            return String(localized: "person_data_editing_failed")
        case .dataDeletionFailed:
            return String(localized: "person_data_deletion_failed")
        case .unknownError:
            return String(localized: "person_unknown_error")
        }
    }
}
