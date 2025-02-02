//
//  UserDataStoringManager.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

protocol UserDataStoringManagerProtocol {
    var currentUser: User? { get }
    func fetchUserData(userID: String) async throws
    func storeUserData(userID: String, fullName: String, email: String, profileImage: UIImage?) async throws
    func updateUserData(updatedUser: User) async throws
    func updateUserData(updatedImage: UIImage, updatedUser: User) async throws
}

final class UserDataStoringManager: UserDataStoringManagerProtocol {
    static let shared = UserDataStoringManager()
    
    var currentUser: User?
    private let firestore: Firestore
    private let storage: Storage
    
    private init(firestore: Firestore = Firestore.firestore(),
         storage: Storage = Storage.storage()) {
        self.firestore = firestore
        self.storage = storage
    }
    
    // MARK: - Fetch User Data
    func fetchUserData(userID: String) async throws {
        do {
            let userSnapshot = try await firestore.collection("users").document(userID).getDocument()
            
            guard let data = userSnapshot.data() else {
                throw DataStoringError.fetchDataFailed
            }
            
            self.currentUser = try decodeUserData(data)
        } catch {
            print("UserDataStoringManager: Error fetching user data with error \(error.localizedDescription)")
            throw DataStoringError.fetchDataFailed
        }
    }
    
    // MARK: - Store User Data
    func storeUserData(userID: String, fullName: String, email: String, profileImage: UIImage?) async throws {
        let currentDate = Date()
        var imageURL: String? = nil
        
        if let profileImage = profileImage {
            imageURL = try await uploadProfileImage(image: profileImage, imageName: "profileImage_\(userID)")
        }
        
        let newUser = User(
            userId: userID,
            fullName: fullName,
            email: email,
            imageURL: imageURL,
            createdAt: currentDate,
            lastLogin: currentDate
        )
        
        try await saveUserDataToFirestore(user: newUser, userID: userID)
    }
    
    // MARK: - Update User Data
    func updateUserData(updatedUser: User) async throws {
        try await saveUserDataToFirestore(user: updatedUser, userID: updatedUser.userID)
        self.currentUser = updatedUser
    }

    func updateUserData(updatedImage: UIImage, updatedUser: User) async throws {
        let imageName = "profileImage_\(updatedUser.userID)"
        
        let newImageURL = try await uploadProfileImage(image: updatedImage, imageName: imageName)
        
        var updatedUser: User = updatedUser
        updatedUser.imageURL = newImageURL
        
        try await saveUserDataToFirestore(user: updatedUser, userID: updatedUser.userID)
        self.currentUser = updatedUser
    }
    
    // MARK: - Private Methods
    private func saveUserDataToFirestore(user: User, userID: String) async throws {
        do {
            let encodedUser = try Firestore.Encoder().encode(user)
            try await firestore.collection("users").document(userID).setData(encodedUser)
            logMessage("User data saved/updated successfully")
        } catch {
            logMessage("Error saving user data with error \(error.localizedDescription)")
            throw DataStoringError.savingUserDataFailed
        }
    }
    
    private func uploadProfileImage(image: UIImage, imageName: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
            throw DataStoringError.imageCompressionFailed
        }
        
        let storageRef = storage.reference(withPath: "userProfileImages/\(imageName).jpg")
        do {
            _ = try await storageRef.putDataAsync(imageData)
            return try await storageRef.downloadURL().absoluteString
        } catch {
            logMessage("Error uploading image with error \(error.localizedDescription)")
            throw DataStoringError.uploadFailed
        }
    }
    
    private func decodeUserData(_ data: [String: Any]) throws -> User {
        do {
            return try Firestore.Decoder().decode(User.self, from: data)
        } catch {
            logMessage("Error decoding User with error \(error.localizedDescription)")
            throw DataStoringError.decodingFailed
        }
    }
    
    private func logMessage(_ message: String) {
        print("UserDataStoringManager: \(message)")
    }
}
