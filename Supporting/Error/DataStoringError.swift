//
//  DataStoringError.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation

enum DataStoringError: LocalizedError {
    case fetchDataFailed
    case savingUserDataFailed
    case decodingFailed
    case imageCompressionFailed
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .fetchDataFailed:
            return "Failed to fetch user data, Please try again later"
        case .savingUserDataFailed:
            return "Failed to save user data, Please try again later"
        case .decodingFailed:
            return "Failed to decode user data."
        case .imageCompressionFailed:
            return "Image compression failed."
        case .uploadFailed:
            return "Image upload failed, Please try again later"
        }
    }
}
