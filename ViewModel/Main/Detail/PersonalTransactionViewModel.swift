//
//  PersonalTransactionViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import Foundation

protocol PersonalTransactionViewModelProtocol {
    var delegate: PersonalTransactionViewModelDelegate? { get set }
    var lendingTransactions: [Transaction] { get }
    var borrowingTransactions: [Transaction] { get }
    func fetchPersonalTransactions()
    func setPersonalDetail()
    func toggleTransactionStatus(from transactionIndex: Int, isLending: Bool)
    func deleteTransaction(from transactionIndex: Int, isLending: Bool)
}

protocol PersonalTransactionViewModelDelegate: AnyObject {
    func didSetPersonalDetail(person: Person)
    func reloadView(isEmpty: Bool)
    func showAlert(title: String, message: String)
}

class PersonalTransactionViewModel: PersonalTransactionViewModelProtocol {
    var delegate: PersonalTransactionViewModelDelegate?
    var lendingTransactions: [Transaction]
    var borrowingTransactions: [Transaction]
    
    private var person: Person
    private var transactionManager: TransactionDataStoringManagerProtocol
    private var dataStoringManager: UserDataStoringManagerProtocol
    
    init(person: Person, transactionManager: TransactionDataStoringManagerProtocol = TransactionDataStoringManager.shared, dataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.person = person
        self.transactionManager = transactionManager
        self.dataStoringManager = dataStoringManager
        self.lendingTransactions = []
        self.borrowingTransactions = []
    }
    
    func setPersonalDetail() {
        delegate?.didSetPersonalDetail(person: person)
    }
    
    func fetchPersonalTransactions() {
        let personalTransaction = transactionManager.transactionData.filter { transaction in
            transaction.personID == person.personID
        }
        
        lendingTransactions = personalTransaction.filter{ transaction in
            transaction.isLend
        }
        
        borrowingTransactions = personalTransaction.filter{ transaction in
            !transaction.isLend
        }
        
        delegate?.reloadView(isEmpty: lendingTransactions.isEmpty
                             && borrowingTransactions.isEmpty)
    }
    
    func toggleTransactionStatus(from transactionIndex: Int, isLending: Bool) {
        guard let userID = dataStoringManager.currentUser?.userID else { return }
        
        var transactionID: String
        
        if isLending {
            lendingTransactions[transactionIndex].isPaid.toggle()
            transactionID = lendingTransactions[transactionIndex].transactionID
        } else {
            borrowingTransactions[transactionIndex].isPaid.toggle()
            transactionID = borrowingTransactions[transactionIndex].transactionID
        }
        
        Task {
            do {
                try await transactionManager.toggleTransactionPaidStatus(from: transactionID, userID: userID)
            } catch {
                await MainActor.run {
                    delegate?.showAlert(title: String(localized: "person_toggle_transaction_failed_title"),
                                        message: error.localizedDescription)
                }
            }
        }
    }
    
    func deleteTransaction(from transactionIndex: Int, isLending: Bool) {
        guard let userID = dataStoringManager.currentUser?.userID else { return }
        
        var transactionID: String
        
        if isLending {
            transactionID = lendingTransactions[transactionIndex].transactionID
            lendingTransactions.remove(at: transactionIndex)
        } else {
            transactionID = borrowingTransactions[transactionIndex].transactionID
            borrowingTransactions.remove(at: transactionIndex)
        }
        
        Task {
            do {
                try await transactionManager.deleteTransactionData(from: transactionID, userID: userID)
                await MainActor.run {
                    delegate?.reloadView(isEmpty: lendingTransactions.isEmpty
                                         && borrowingTransactions.isEmpty)
                }
            } catch {
                await MainActor.run {
                    delegate?.showAlert(title: String(localized: "person_delete_transaction_failed_title"),
                                        message: error.localizedDescription)
                }
            }
        }
    }
}
