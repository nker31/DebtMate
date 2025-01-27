//
//  TransactionHistoryViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/15/24.
//

import Foundation

protocol TransactionHistoryViewModelProtocol {
    var delegate: TransactionHistoryViewModelDelegate? { get set }
    var groupedTransactions : [(date: Date, transactions: [Transaction])] { get }
}

protocol TransactionHistoryViewModelDelegate: AnyObject {
    func reloadTransactionHistory()
}

class TransactionHistoryViewModel: TransactionHistoryViewModelProtocol {
    weak var delegate: TransactionHistoryViewModelDelegate?
    var groupedTransactions: [(date: Date, transactions: [Transaction])]
    
    private let transactionManager: TransactionDataStoringManagerProtocol
    private let personManager: PersonDataStoringManagerProtocol
    
    init(transactionManager: TransactionDataStoringManagerProtocol = TransactionDataStoringManager.shared, personManager: PersonDataStoringManagerProtocol = PersonDataStoringManager.shared) {
        self.groupedTransactions = []
        self.transactionManager = transactionManager
        self.personManager = personManager
    }

    func fetchTransactions() {
        let transactions = transactionManager.transactionData
        groupTransactionsByDate(transactions)
        delegate?.reloadTransactionHistory()
    }
    
    func groupTransactionsByDate(_ transactions: [Transaction]) {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction -> Date in
            let components = calendar.dateComponents([.year, .month, .day], from: transaction.createdAt)
            return calendar.date(from: components) ?? Date()
        }
        
        groupedTransactions = grouped.sorted { $0.key > $1.key }
            .map { (date: $0.key, transactions: $0.value) }
    }
    
    func findPersonName(from personID: String) -> String? {
        return personManager.getPersonName(for: personID)
    }
}
