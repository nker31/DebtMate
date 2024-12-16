//
//  EditTransactionViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/16/24.
//

import Foundation

protocol EditTransactionViewModelProtocol {
    var delegate: EditTransactionViewModelDelegate? { get }
    func setupTransactionDetails()
    func updateTransactionDetails(amount: String?, description: String?, date: Date?)
    func validateTransaction(amount: String?, description: String?, date: Date?)
    func toggleDuaDate(isEnabled: Bool)
}

protocol EditTransactionViewModelDelegate: AnyObject {
    func didStateChange(to state: ViewState)
    func didSetupTransactionDetails(transaction: Transaction)
    func didValidateTransactionDetails(isValid: Bool)
    func didToggleDueDate(isEnabled: Bool)
    func didUpdateTransactionDetails(transaction: Transaction)
}

class EditTransactionViewModel: EditTransactionViewModelProtocol {
    weak var delegate: EditTransactionViewModelDelegate?
    
    private let transactionManager: TransactionDataStoringManagerProtocol
    private let userManager: UserDataStoringManagerProtocol
    private let personDataStoringManager: PersonDataStoringManagerProtocol
    private let notificationManager: NotificationManagerProtocol
    private var transaction: Transaction
    private var isEnabledDueDate: Bool = false
    private var originalDueDate: Date?
    private var viewState: ViewState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didStateChange(to: self.viewState)
            }
        }
    }
    
    init(transaction: Transaction, transactionManager: TransactionDataStoringManagerProtocol = TransactionDataStoringManager.shared, userManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared, personDataStoringManager: PersonDataStoringManagerProtocol = PersonDataStoringManager.shared, notificationManager: NotificationManagerProtocol = NotificationManager.shared) {
        self.transaction = transaction
        self.isEnabledDueDate = transaction.dueDate != nil
        self.originalDueDate = transaction.dueDate
        self.transactionManager = transactionManager
        self.userManager = userManager
        self.personDataStoringManager = personDataStoringManager
        self.notificationManager = notificationManager
    }
    
    func setupTransactionDetails() {
        delegate?.didSetupTransactionDetails(transaction: transaction)
    }
    
    func validateTransaction(amount: String?, description: String?, date: Date?) {
        guard let amount else { return }
        
        let isAmountValid = validateAmount(amount)
        let isDescriptionValid = validateDescription(description)
        let isValidDueDate = validateDueDate(date)
        
        let isValid = isAmountValid || isDescriptionValid || isValidDueDate
        delegate?.didValidateTransactionDetails(isValid: isValid)
    }
    
    func updateTransactionDetails(amount: String?, description: String?, date: Date?) {
        guard let amount, let floatAmount = Float(amount) else {
            return
        }
        
        guard let userID = userManager.currentUser?.userID else {
            return
        }
        
        let dueDate = isEnabledDueDate ? date : nil
        
        self.transaction.amount = floatAmount
        self.transaction.description = description
        self.transaction.dueDate = dueDate
        
        viewState = .loading
        
        Task {
            do {
                try await transactionManager.updateTransactionData(transaction, userID: userID)
                setTransactionReminder(dueDate: dueDate, amount: floatAmount)
                viewState = .success
                await MainActor.run {
                    delegate?.didUpdateTransactionDetails(transaction: transaction)
                }
            } catch {
                viewState = .failure(error)
            }
        }
    }
    
    func toggleDuaDate(isEnabled: Bool) {
        self.isEnabledDueDate = isEnabled
        delegate?.didToggleDueDate(isEnabled: isEnabled)
    }
    
    // MARK: - Private Methods
    private func validateAmount(_ amount: String) -> Bool {
        return !amount.isEmpty && amount != "0" && amount != String(transaction.amount)
    }

    private func validateDescription(_ description: String?) -> Bool {
        return description != transaction.description
    }

    private func validateDueDate(_ date: Date?) -> Bool {
        guard isEnabledDueDate else {
            return originalDueDate != nil
        }
        
        if let originalDueDate = originalDueDate {
            guard let newDueDate = date else { return false }
            return originalDueDate != newDueDate && originalDueDate < newDueDate
        } else {
            return date != nil
        }
    }
    
    private func setTransactionReminder(dueDate: Date?, amount: Float) {
        guard isEnabledDueDate, let dueDate else { return }
        guard !transaction.isPaid else { return }
        
        let personName = personDataStoringManager.getPersonName(for: transaction.personID) ?? "Unknown"
        
        notificationManager.setTransactionReminder(isLend: transaction.isLend,
                                                   personName: personName,
                                                   amount: amount,
                                                   dueDate: dueDate)
    }
}
