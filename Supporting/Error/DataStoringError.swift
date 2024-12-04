//
//  DataStoringError.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation

enum DataStoringError: LocalizedError {
    case fetchDataFailed(reason: String)
    case savingUserDataFailed(reason: String)
    case decodingFailed
    case imageCompressionFailed
    case uploadFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .fetchDataFailed(let reason): return "Failed to fetch user data: \(reason)"
        case .savingUserDataFailed(let reason): return "Failed to save user data: \(reason)"
        case .decodingFailed: return "Failed to decode user data."
        case .imageCompressionFailed: return "Image compression failed."
        case .uploadFailed(let reason): return "Image upload failed: \(reason)"
        }
    }
}
