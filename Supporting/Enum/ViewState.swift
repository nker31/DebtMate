//
//  ViewState.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/9/24.
//

import Foundation

enum ViewState {
    case idle
    case loading
    case success
    case failure(Error)
}
