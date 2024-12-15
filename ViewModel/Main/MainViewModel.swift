//
//  MainViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import Foundation

protocol MainViewModelProtocol {
    var delegate: MainViewModelDelegate? { get set }
    var personData: [Person] { get }
    func fetchUserData()
    func calculatePersonalBalance(for personID: String) -> Float?
    func calculateTotalBalance() -> (Float, Float)
    func deletePerson(from personIndex: Int)
}

protocol MainViewModelDelegate: AnyObject {
    func didStateChange(to viewState: ViewState)
}

class MainViewModel: MainViewModelProtocol {
    weak var delegate: MainViewModelDelegate?
    
    var personData: [Person] {
        personDataStoringManager.personData
    }
    
    var transactionData: [Transaction] {
        transactionDataStoringManager.transactionData
    }
    
    var viewState: ViewState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didStateChange(to: self.viewState)
            }
        }
    }
    
    var authManager: AuthenticationManagerProtocol
    var userDataStoringManager: UserDataStoringManagerProtocol
    var personDataStoringManager: PersonDataStoringManagerProtocol
    var transactionDataStoringManager: TransactionDataStoringManagerProtocol
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared, userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared,
         personDataStoringManager: PersonDataStoringManagerProtocol = PersonDataStoringManager.shared,
         transactionDataStoringManager: TransactionDataStoringManagerProtocol = TransactionDataStoringManager.shared) {
        self.authManager = authManager
        self.userDataStoringManager = userDataStoringManager
        self.personDataStoringManager = personDataStoringManager
        self.transactionDataStoringManager = transactionDataStoringManager
    }
    
    func fetchUserData() {
        viewState = .loading
        Task {
            do {
                guard let userSessionID = authManager.userSession?.uid else {
                    throw AuthenticationError.noUserSession
                }
                
                try await userDataStoringManager.fetchUserData(userID: userSessionID)
                
                try await personDataStoringManager.fetchPersonData(userID: userSessionID)
                
                try await transactionDataStoringManager.fetchTransactionData(from: userSessionID)
                
                viewState = .success
            } catch {
                viewState = .failure(error)
            }
        }
    }
    
    func calculatePersonalBalance(for personID: String) -> Float? {
        let personalTransactions = transactionDataStoringManager.transactionData.filter { $0.personID == personID && !$0.isPaid }
        
        guard !personalTransactions.isEmpty else {
            return nil
        }
        
        let (totalLend, totalBorrow) = personalTransactions.reduce(into: (lend: Float(0), borrow: Float(0))) { result, transaction in
            if transaction.isLend {
                result.lend += transaction.amount
            } else {
                result.borrow += transaction.amount
            }
        }
        
        return totalLend - totalBorrow
    }
    
    func calculateTotalBalance() -> (Float, Float) {
        let transactionData = transactionDataStoringManager.transactionData.filter { !$0.isPaid }
        
        guard !transactionData.isEmpty else {
            return (0, 0)
        }
        
        let (totalLend, totalBorrow) = transactionData.reduce(into: (lend: Float(0), borrow: Float(0))) { result, transaction in
            if transaction.isLend {
                result.lend += transaction.amount
            } else {
                result.borrow += transaction.amount
            }
        }
        
        return (totalLend, totalBorrow)
    }
    
    func deletePerson(from personIndex: Int) {
        guard let userID = userDataStoringManager.currentUser?.userID else {
            viewState = .failure(DataStoringError.currentUserNotFound)
            return
        }
        
        let selectedPersonID = personData[personIndex].personID
        
        Task {
            do {
                try await personDataStoringManager.deletePerson(from: selectedPersonID, userID: userID)
                try await transactionDataStoringManager.deleteAllPersonalTransaction(from: selectedPersonID, userID: userID)
                viewState = .success
            } catch {
                viewState = .failure(error)
            }
        }
    }
}
