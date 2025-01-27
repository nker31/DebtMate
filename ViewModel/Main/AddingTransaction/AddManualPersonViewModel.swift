//
//  AddManualPersonViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import Foundation
import UIKit

protocol AddManualPersonViewModelProtocol {
    var delegate: AddManualPersonViewModelDelegate? { get set }
    func addPerson(fullName: String?, phoneNumber: String?, profileImage: UIImage?)
    func validatePersonDetails(fullName: String?, phoneNumber: String?)
}

protocol AddManualPersonViewModelDelegate: AnyObject {
    func didAddManualPerson(contact: Contact)
    func didValidatePersonDetails(isValid: Bool)
}

class AddManualPersonViewModel: AddManualPersonViewModelProtocol {
    weak var delegate: AddManualPersonViewModelDelegate?
    
    func addPerson(fullName: String?, phoneNumber: String?, profileImage: UIImage?) {
        guard let fullName, InputValidator.validateFullName(fullName) else { return }
        
        let contact = Contact(name: fullName,
                              phoneNumber: phoneNumber,
                              profileImage: profileImage)
    
        delegate?.didAddManualPerson(contact: contact)
    }
    
    func validatePersonDetails(fullName: String?, phoneNumber: String?) {
        guard let fullName, let phoneNumber else { return }
        
        let isValid = InputValidator.validateFullName(fullName) && InputValidator.validatePhoneNumber(phoneNumber)
        
        delegate?.didValidatePersonDetails(isValid: isValid)
    }
}
