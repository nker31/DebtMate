//
//  AddTransactionViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation
import UIKit

protocol AddTransactionViewModelProtocol {
    var delegate: AddTransactionViewModelDelegate? { get set }
    var hasSelection: Bool { get }
    func setSelectedContact(contact: Contact)
    func setSelectedPerson(person: Person)
    func clearSelection()
    func setTransactionType(isLending: Bool)
    func enableDueDate(isEnabled: Bool)
    func handleAddTransaction(amount: String?, description: String?, dueDate: Date?)
}

protocol AddTransactionViewModelDelegate: AnyObject {
    func didClearSelection()
    func didSetSelectedPerson(name: String)
    func didSetTransactionType()
    func didEnableDueDate(isEnabled: Bool)
    func didStateChange(to state: ViewState)
    func showAlert(title: String, message: String)
}

class AddTransactionViewModel: AddTransactionViewModelProtocol {
    weak var delegate: AddTransactionViewModelDelegate?
    var hasSelection: Bool {
        selectedPerson != nil || selectedContact != nil
    }

    private var isLend: Bool
    private var selectedPerson: Person?
    private var selectedContact: Contact?
    private var isEnabledDueDate: Bool = false
    private var viewState: ViewState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didStateChange(to: self.viewState)
            }
        }
    }

    var personDataStoringManager: PersonDataStoringManagerProtocol
    var userDataStoringManager: UserDataStoringManagerProtocol
    var transactionDataStoringManager: TransactionDataStoringManagerProtocol

    init(personDataStoringManager: PersonDataStoringManagerProtocol = PersonDataStoringManager.shared, userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared, transactionDataStoringManager: TransactionDataStoringManagerProtocol = TransactionDataStoringManager.shared) {
        self.isLend = true
        self.personDataStoringManager = personDataStoringManager
        self.userDataStoringManager = userDataStoringManager
        self.transactionDataStoringManager = transactionDataStoringManager
    }
    
    func setSelectedContact(contact: Contact) {
        selectedContact = contact
        selectedPerson = nil
        delegate?.didSetSelectedPerson(name: contact.name)
    }
    
    func setSelectedPerson(person: Person) {
        selectedPerson = person
        selectedContact = nil
        delegate?.didSetSelectedPerson(name: person.fullName)
    }
    
    func clearSelection() {
        selectedPerson = nil
        selectedContact = nil
        delegate?.didClearSelection()
    }
    
    func setTransactionType(isLending: Bool) {
        isLend = isLending
        delegate?.didSetTransactionType()
    }
    
    func enableDueDate(isEnabled: Bool) {
        isEnabledDueDate = isEnabled
        delegate?.didEnableDueDate(isEnabled: isEnabled)
    }
    
    func handleAddTransaction(amount: String?, description: String?, dueDate: Date?) {
        guard let userID = userDataStoringManager.currentUser?.userID else { return }
        
        guard hasSelection else {
            delegate?.showAlert(title: String(localized: "add_transaction_failed_title"),
                                message: String(localized: "add_transaction_no_selected_person"))
            return
        }
        
        guard let amountString = amount, let amountValue = Float(amountString) else {
            delegate?.showAlert(title: String(localized: "add_transaction_failed_title"),
                                message: String(localized: "add_transaction_no_amount"))
            return
        }
        
        let preferredDueDate = isEnabledDueDate ? dueDate : nil
        
        viewState = .loading
        
        Task {
            if let selectedPerson {
                // Perform add transaction with person ID
            } else if let selectedContact {
                await handleAddTransactionForContact(contact: selectedContact,
                                                     amount: amountValue,
                                                     description: description,
                                                     dueDate: preferredDueDate,
                                                     to: userID)
                viewState = .success
            }
        }
    }
    
    func handleAddPersonFromContact(contact: Contact, to userID: String) async -> String? {
        do {
            return try await personDataStoringManager.addPerson(from: contact, to: userID)
        } catch {
            viewState = .failure(error)
            return nil
        }
    }
    
    func handleAddTransactionForContact(contact: Contact, amount: Float, description: String?, dueDate: Date?, to userID: String) async {
        guard let personID = await handleAddPersonFromContact(contact: contact, to: userID) else {
            return
        }
        
        do {
            try await transactionDataStoringManager.addTransactionData(personID: personID,
                                                                       amount: amount,
                                                                       description: description,
                                                                       dueDate: dueDate,
                                                                       isLend: isLend,
                                                                       to: userID)
        } catch {
            viewState = .failure(error)
        }
    }
}
