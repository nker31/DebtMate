//
//  DataStoringError.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation

enum DataStoringError: LocalizedError {
    case currentUserNotFound
    case fetchDataFailed
    case savingUserDataFailed
    case decodingFailed
    case imageCompressionFailed
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .currentUserNotFound:
            return String(localized: "data_storing_error_current_user_not_found")
        case .fetchDataFailed:
            return String(localized: "data_storing_error_fetch_data_failed")
        case .savingUserDataFailed:
            return String(localized: "data_storing_error_saving_user_data_failed")
        case .decodingFailed:
            return String(localized: "data_storing_error_decoding_failed")
        case .imageCompressionFailed:
            return String(localized: "data_storing_error_image_compression_failed")
        case .uploadFailed:
            return String(localized: "data_storing_error_upload_failed")
        }
    }
}
