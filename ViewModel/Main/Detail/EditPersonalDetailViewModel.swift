//
//  EditPersonalDetailViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/13/24.
//

import Foundation
import UIKit

protocol EditPersonalDetailViewModelProtocol {
    var delegate: EditPersonalDetailViewModelDelegate? { get set }
    var newImage: UIImage? { get set }
    func updatePersonalDetail(newName: String?, newPhone: String?)
    func validatePersonalDetail(newName: String?, newPhone: String?, originalImage: UIImage?)
    func setupPersonDetail()
    func setSelectedImage(image: UIImage)
}

protocol EditPersonalDetailViewModelDelegate: AnyObject {
    func didValidatePersonalDetail(isValid: Bool)
    func didSetupPersonalDetail(person: Person)
    func didStateChange(to state: ViewState)
}

class EditPersonalDetailViewModel: EditPersonalDetailViewModelProtocol {
    weak var delegate: EditPersonalDetailViewModelDelegate?
    var newImage: UIImage?
    
    private var person: Person
    private var personManager: PersonDataStoringManagerProtocol
    private var userManager: UserDataStoringManagerProtocol
    
    private var viewState: ViewState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didStateChange(to: self.viewState)
            }
        }
    }
    
    init(person: Person, personManager: PersonDataStoringManagerProtocol = PersonDataStoringManager.shared, userManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.person = person
        self.personManager = personManager
        self.userManager = userManager
    }
    
    func setupPersonDetail() {
        delegate?.didSetupPersonalDetail(person: person)
    }

    func updatePersonalDetail(newName: String?, newPhone: String?) {
        guard let userID = userManager.currentUser?.userID else { return }
        
        guard let newName, let newPhone else { return }
        
        person.fullName = newName
        person.phoneNumber = newPhone
        
        viewState = .loading
        
        Task {
            do {
                if let newImage {
                    try await personManager.updatePerson(withImage: newImage,
                                                         updatedPerson: person,
                                                         for: userID)
                } else {
                    try await personManager.updatePerson(updatedPerson: person,
                                                         for: userID)
                }
                
                viewState = .success
            } catch {
                viewState = .failure(error)
            }
        }
    }
    
    func validatePersonalDetail(newName: String?, newPhone: String?, originalImage: UIImage?) {
        guard let newName, let newPhone else { return }
        
        let isValidTextInput = InputValidator.validateFullName(newName) && InputValidator.validatePhoneNumber(newPhone)
        
        guard isValidTextInput else {
            delegate?.didValidatePersonalDetail(isValid: false)
            return
        }
        
        let isNameChanged = newName != person.fullName
        let isPhoneChanged = newPhone != person.phoneNumber
        let isImageChanged = newImage != originalImage && newImage != nil && originalImage != nil
        
        let isValid = isNameChanged || isPhoneChanged || isImageChanged
        
        delegate?.didValidatePersonalDetail(isValid: isValid)
    }
    
    func setSelectedImage(image: UIImage) {
        self.newImage = image
    }
}
