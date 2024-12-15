//
//  TransactionDetailViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/15/24.
//

import Foundation

protocol TransactionDetailViewModelProtocol {
    var delegate: TransactionDetailViewModelDelegate? { get set }
    func setupTransactionData()
    func toggleTransactionStatus()
    func deleteTransaction()
}

protocol TransactionDetailViewModelDelegate: AnyObject {
    func didSetupTransactionData(transaction: Transaction)
    func didToggleTransactionStatus(isPaid: Bool)
    func didToggleTransactionFailed(error: Error)
    func didDeleteTransaction()
}

class TransactionDetailViewModel: TransactionDetailViewModelProtocol {
    weak var delegate: TransactionDetailViewModelDelegate?
    
    private var transaction: Transaction
    private var userManager: UserDataStoringManagerProtocol
    private var transactionManager: TransactionDataStoringManagerProtocol
    
    init(transaction: Transaction, transactionManager: TransactionDataStoringManagerProtocol = TransactionDataStoringManager.shared, userManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.transaction = transaction
        self.transactionManager = transactionManager
        self.userManager = userManager
    }
    
    func setupTransactionData() {
        delegate?.didSetupTransactionData(transaction: transaction)
    }
    
    func toggleTransactionStatus() {
        guard let userID = userManager.currentUser?.userID else {
            return
        }
    
        self.transaction.isPaid.toggle()
        delegate?.didToggleTransactionStatus(isPaid: transaction.isPaid)
        
        Task {
            do {
                try await transactionManager.toggleTransactionPaidStatus(from: transaction.transactionID, userID: userID)
            } catch {
                await MainActor.run {
                    delegate?.didToggleTransactionFailed(error: error)
                }
            }
        }
    }
    
    func deleteTransaction() {
        guard let userID = userManager.currentUser?.userID else {
            return
        }
        
        Task {
            do {
                try await transactionManager.deleteTransactionData(from: transaction.transactionID, userID: userID)
                await MainActor.run {
                    delegate?.didDeleteTransaction()
                }
                
            } catch {
                await MainActor.run {
                    delegate?.didToggleTransactionFailed(error: error)
                }
            }
        }
    }
}
