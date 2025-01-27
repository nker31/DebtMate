//
//  DateExtension.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import Foundation

extension Date {
    func formatDate(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
