//
//  ContactSelectionViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import Foundation

protocol ContactSelectionViewModelProtocol {
    var delegate: ContactSelectionViewModelDelegate? { get set }
    var filteredContacts: [Contact] { get }
    func askForContactAccess()
    func fetchContacts()
    func handleSearchTextChanged(text: String)
}

protocol ContactSelectionViewModelDelegate: AnyObject {
    func reloadContacts()
    func toggleEmtpyState(isEmpty: Bool)
    func toggleAccessDeniedState(isDenied: Bool)
}

class ContactSelectionViewModel: ContactSelectionViewModelProtocol {
    weak var delegate: ContactSelectionViewModelDelegate?
    var contacts: [Contact] = []
    var filteredContacts: [Contact] = [] {
        didSet {
            delegate?.toggleEmtpyState(isEmpty: filteredContacts.isEmpty)
        }
    }
    
    private let contactManager: ContactManagerProtocol
    
    init(contactManager: ContactManagerProtocol = ContactManager.shared) {
        self.contactManager = contactManager
    }
    
    func askForContactAccess() {
        contactManager.authorizeContactAccess { [weak self] granted in
            if granted {
                self?.fetchContacts()
            } else {
                DispatchQueue.main.async {
                    self?.delegate?.toggleAccessDeniedState(isDenied: !granted)
                }
            }
        }
    }
    
    func fetchContacts() {
        guard contactManager.isContactPermissionGranted else {
            return
        }
        
        contactManager.fetchContacts { [weak self] contacts in
            self?.filteredContacts = contacts
            self?.contacts = contacts
            
            DispatchQueue.main.async {
                self?.delegate?.reloadContacts()
            }
        }
    }
    
    func handleSearchTextChanged(text: String) {
        guard contactManager.isContactPermissionGranted else {
            return
        }
        
        if text.isEmpty {
            filteredContacts = contacts
        } else {
            filteredContacts = contacts.filter { $0.name.lowercased().starts(with: text.lowercased())}
        }

        delegate?.reloadContacts()
    }
}
