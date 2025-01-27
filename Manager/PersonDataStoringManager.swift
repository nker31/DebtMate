//
//  PersonDataStoringManager.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

protocol PersonDataStoringManagerProtocol {
    var personData: [Person] { get }
    func addPerson(from fullname: String, phoneNumber: String?, profileImage: UIImage?, to userID: String) async throws -> String
    func addPerson(from contact: Contact, to userID: String) async throws -> String
    func fetchPersonData(userID: String) async throws
    func deletePerson(from personID: String, userID: String) async throws
    func updatePerson(updatedPerson: Person, for userID: String) async throws
    func updatePerson(withImage updatedImage: UIImage, updatedPerson: Person, for userID: String) async throws
    func getPersonName(for personID: String) -> String?
}

class PersonDataStoringManager: PersonDataStoringManagerProtocol {
    static let shared = PersonDataStoringManager()
    
    private let firestore: Firestore
    private let storageRef: StorageReference
    private var personNameCache: [String: String]
    
    var personData: [Person]
    
    init(firestore: Firestore = Firestore.firestore(),
         storageRef: StorageReference = Storage.storage().reference(),
         personData: [Person] = [],
         personNameCache: [String: String] = [:]) {
        self.firestore = firestore
        self.storageRef = storageRef
        self.personData = personData
        self.personNameCache = personNameCache
    }
    
    // MARK: - Public Method
    func addPerson(from fullname: String, phoneNumber: String?, profileImage: UIImage?, to userID: String) async throws -> String {
        if let existingPersonID = checkIfPersonDataExists(from: fullname, phoneNumber: phoneNumber) {
            return existingPersonID
        }
            
        do {
            let person = try await createPerson(personName: fullname,
                                                phoneNumber: phoneNumber,
                                                profileImage: profileImage)
            try await storePerson(person: person, to: userID)
            personData.append(person)
            
            return person.personID
        } catch {
            throw error
        }
    }
    
    func addPerson(from contact: Contact, to userID: String) async throws -> String {
        if let existingPersonID = checkIfPersonDataExists(from: contact.name, phoneNumber: contact.phoneNumber) {
            return existingPersonID
        }
        
        do {
            let person = try await createPerson(personName: contact.name,
                                                phoneNumber: contact.phoneNumber,
                                                profileImage: contact.profileImage)
            try await storePerson(person: person, to: userID)
            personData.append(person)
            
            return person.personID
        } catch {
            throw error
        }
    }
    
    func fetchPersonData(userID: String) async throws {
        let personCollection = firestore.collection("users").document(userID).collection("persons")
        
        do {
            let snapshot = try await personCollection.getDocuments()
            self.personData = snapshot.documents.compactMap { doc in
                do {
                    return try Firestore.Decoder().decode(Person.self, from: doc.data())
                } catch {
                    print("Failed to decode person data for document ID: \(doc.documentID)")
                    return nil
                }
            }
        } catch {
            throw PersonError.fetchDataFailed
        }
    }
    
    func deletePerson(from personID: String, userID: String) async throws {
        guard let personIndex = getPersonIndex(from: personID) else {
            return
        }
        
        let hasImage = personData[personIndex].imageURL != nil
        
        personData.remove(at: personIndex)
        try await deletePersonDocument(userID: userID, personID: personID)
        
        if hasImage {
            let imageName = "person_\(personID)"
            try await deletePersonImage(imageName: imageName)
        }
    }
    
    func getPersonName(for personID: String) -> String? {
        if let cachedName = personNameCache[personID] {
            return cachedName
        }
        
        if let person = personData.first(where: { $0.personID == personID }) {
            personNameCache[personID] = person.fullName
            return person.fullName
        }
        
        return nil
    }
    
    func updatePerson(updatedPerson: Person, for userID: String) async throws {
        guard let personIndex = getPersonIndex(from: updatedPerson.personID) else {
            throw PersonError.dataEditingFailed
        }
        
        personData[personIndex] = updatedPerson
        try await updatePersonData(updatedPerson, for: userID)
    }
    
    func updatePerson(withImage updatedImage: UIImage, updatedPerson: Person, for userID: String) async throws {
        guard let personIndex = getPersonIndex(from: updatedPerson.personID) else {
            throw PersonError.dataEditingFailed
        }
        
        let imageName = "person_\(updatedPerson.personID)"
        let newImageURL = try await uploadPersonProfileImage(image: updatedImage,
                                                             imageName: imageName)
        
        var mutablePerson = updatedPerson
        mutablePerson.imageURL = newImageURL
        personData[personIndex] = mutablePerson
        
        try await updatePersonData(mutablePerson, for: userID)
    }
    
    // MARK: - Private Methods
    private func createPerson(personName: String, phoneNumber: String?, profileImage: UIImage?) async throws -> Person {
        let personID = UUID().uuidString
        var imageURL: String?
        
        if let profileImage {
            let imageName = "person_\(personID)"
            
            do {
                imageURL = try await uploadPersonProfileImage(image: profileImage, imageName: imageName)
            } catch {
                throw error
            }
        }
        
        let person = Person(personID: personID,
                            fullName: personName,
                            phoneNumber: phoneNumber,
                            imageURL: imageURL)
        
        return person
    }
    
    private func storePerson(person: Person, to userID: String) async throws {
        let personRef = firestore.collection("users").document(userID).collection("persons").document(person.personID)
        
        do {
            try personRef.setData(from: person)
        } catch {
            logMessage(message: "PersonDataStoringManager: Error adding person - \(error.localizedDescription)")
            throw PersonError.dataStoringFailed
        }
    }
    
    private func uploadPersonProfileImage(image: UIImage, imageName: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw DataStoringError.imageCompressionFailed
        }
        
        let imageRef = storageRef.child("personProfileImages/\(imageName).jpg")
        
        do {
            _ = try await imageRef.putDataAsync(imageData)
            let downloadURL = try await imageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            logMessage(message: "Error uploading image - \(error.localizedDescription)")
            throw DataStoringError.uploadFailed
        }
    }
    
    private func updatePersonData(_ person: Person, for userID: String) async throws {
        let personRef = firestore
                    .collection("users")
                    .document(userID)
                    .collection("persons")
                    .document(person.personID)
                
        do {
            try personRef.setData(from: person)
            logMessage(message: "Person data updated successfully")
        } catch {
            logMessage(message: "Person data update failed with error: \(error.localizedDescription)")
            throw PersonError.dataEditingFailed
        }
    }
    
    private func deletePersonDocument(userID: String, personID: String) async throws {
        let personRef = firestore.collection("users")
            .document(userID)
            .collection("persons")
            .document(personID)
        
        do {
            try await personRef.delete()
            logMessage(message: "Person data deleted successfully")
        } catch {
            logMessage(message: "Failed to delete Person data: \(error.localizedDescription)")
            throw PersonError.dataDeletionFailed
        }
    }
    
    private func deletePersonImage(imageName: String) async throws {
        let imageRef = storageRef.child("personProfileImages/\(imageName).jpg")
        
        do {
            try await imageRef.delete()
            logMessage(message: "Person profile image deleted successfully")
        } catch {
            logMessage(message: "delete profile image failed with error: \(error.localizedDescription)")
            throw PersonError.dataDeletionFailed
        }
    }
}

extension PersonDataStoringManager {
    private func checkIfPersonDataExists(from fullName: String, phoneNumber: String?) -> String? {
        let keyToFind = "\(fullName)|\(phoneNumber ?? "")"

        var low = 0
        var high = personData.count - 1

        while low <= high {
            let mid = (low + high) / 2
            let midKey = "\(personData[mid].fullName)|\(personData[mid].phoneNumber ?? "")"

            if midKey == keyToFind {
                return personData[mid].personID
            } else if midKey < keyToFind {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        
        return nil
    }
    
    private func getPersonData(from personID: String) -> Person? {
        return personData.first { $0.personID == personID }
    }
    
    private func getPersonIndex(from personID: String) -> Int? {
        return personData.firstIndex { $0.personID == personID }
    }
    
    private func sortPersonData() {
        personData.sort {
            "\($0.fullName)|\($0.phoneNumber ?? "")" < "\($1.fullName)|\($1.phoneNumber ?? "")"
        }
    }
    
    private func logMessage(message: String) {
        print("PersonDataStoringManager: \(message)")
    }
}
