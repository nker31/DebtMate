//
//  ExistingPersonSelectionViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/12/24.
//

import Foundation

protocol ExistingPersonSelectionViewModelProtocol {
    var delegate: ExistingPersonSelectionViewModelDelegate? { get set }
    var filteredPersonData: [Person] { get }
    func fetchExistingPersons()
    func onSearchTextChanged(_ text: String)
}

protocol ExistingPersonSelectionViewModelDelegate: AnyObject {
    func didReloadPersonData(isEmpty: Bool)
}

class ExistingPersonSelectionViewModel: ExistingPersonSelectionViewModelProtocol {
    weak var delegate: ExistingPersonSelectionViewModelDelegate?
    var filteredPersonData: [Person]
    
    private var personDataStoringManager: PersonDataStoringManagerProtocol
    private var existingPersons: [Person] {
        personDataStoringManager.personData
    }
    
    init(personDataStoringManager: PersonDataStoringManagerProtocol = PersonDataStoringManager.shared) {
        self.personDataStoringManager = personDataStoringManager
        self.filteredPersonData = []
    }
    
    func fetchExistingPersons() {
        filteredPersonData = existingPersons
        delegate?.didReloadPersonData(isEmpty: filteredPersonData.isEmpty)
    }
    
    func onSearchTextChanged(_ text: String) {
        if text.isEmpty {
            filteredPersonData = existingPersons
        } else {
            filteredPersonData = existingPersons.filter { $0.fullName.lowercased().starts(with: text.lowercased())
            }
        }
        
        delegate?.didReloadPersonData(isEmpty: filteredPersonData.isEmpty)
    }
}
