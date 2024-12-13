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
}

protocol PersonalTransactionViewModelDelegate: AnyObject {
    func didSetPersonalDetail(person: Person)
    func reloadView(isEmpty: Bool)
}

class PersonalTransactionViewModel: PersonalTransactionViewModelProtocol {
    var delegate: PersonalTransactionViewModelDelegate?
    var lendingTransactions: [Transaction]
    var borrowingTransactions: [Transaction]
    
    private var person: Person
    private var transactionManager: TransactionDataStoringManagerProtocol
    
    init(person: Person, transactionManager: TransactionDataStoringManagerProtocol = TransactionDataStoringManager.shared) {
        self.person = person
        self.transactionManager = transactionManager
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
}
