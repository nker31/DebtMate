//
//  AddTransactionViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation

protocol AddTransactionViewModelProtocol {
    var delegate: AddTransactionViewModelDelegate? { get set }
    var hasSelection: Bool { get }
    func setSelectedContact(contact: Contact)
    func setSelectedPerson(person: Person)
    func clearSelection()
    func setTransactionType(isLending: Bool)
    func handleAddTransaction()
}

protocol AddTransactionViewModelDelegate: AnyObject {
    func didClearSelection()
    func didSetSelectedPerson(name: String)
    func didSetTransactionType()
}

class AddTransactionViewModel: AddTransactionViewModelProtocol {
    weak var delegate: AddTransactionViewModelDelegate?
    var hasSelection: Bool {
        selectedPerson != nil || selectedContact != nil
    }

    var isLend: Bool
    var selectedPerson: Person?
    var selectedContact: Contact?

    init() {
        self.isLend = true
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
    
    func handleAddTransaction() {
        
    }
}
