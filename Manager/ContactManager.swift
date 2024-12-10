//
//  ContactManager.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import Foundation
import UIKit
import Contacts

protocol ContactManagerProtocol {
    var isContactPermissionGranted: Bool { get }
    func authorizeContactAccess(completion: @escaping (Bool) -> Void)
    func fetchContacts(completion: @escaping ([Contact]) -> Void)
}

class ContactManager: ContactManagerProtocol {
    static let shared = ContactManager()
    private let application: UIApplication
    private let contactStore: CNContactStore
    
    var isContactPermissionGranted: Bool
    
    init(application: UIApplication = .shared,
         contactStore: CNContactStore = CNContactStore(),
         isContactPermissionGranted: Bool = false) {
        self.application = application
        self.contactStore = contactStore
        self.isContactPermissionGranted = isContactPermissionGranted
    }
    
    func authorizeContactAccess(completion: @escaping (Bool) -> Void) {
        contactStore.requestAccess(for: .contacts) { [weak self] granted, error in
            self?.isContactPermissionGranted = granted
            completion(granted)
        }
    }
    
    func fetchContacts(completion: @escaping ([Contact]) -> Void) {
        var fetchedContacts: [Contact] = []
        
        let keys = [CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey,
                    CNContactImageDataKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.contactStore.enumerateContacts(with: request, usingBlock: { contact, _ in
                    let fullName = "\(contact.givenName) \(contact.familyName)"
                    let phoneNumber = contact.phoneNumbers.first?.value.stringValue
                    let profileImage = contact.imageData.flatMap { UIImage(data: $0) }

                    let contact = Contact(name: fullName,
                                          phoneNumber: phoneNumber,
                                          profileImage: profileImage)
                    
                    fetchedContacts.append(contact)
                })
                
                let ascendingContact = fetchedContacts.sorted { $0.name < $1.name }
                completion(ascendingContact)
            } catch {
                completion(fetchedContacts)
                self?.logMessage("failed to fetch contacts with error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func logMessage(_ message: String) {
        print("ContactManager: \(message)")
    }
}
