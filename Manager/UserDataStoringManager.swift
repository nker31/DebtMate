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
                throw DataStoringError.fetchDataFailed(reason: "No data found for user ID: \(userID)")
            }
            self.currentUser = try decodeUserData(data)
        } catch let error as DataStoringError {
            throw error
        } catch {
            throw DataStoringError.fetchDataFailed(reason: error.localizedDescription)
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
    
    // MARK: - Private Methods
    private func saveUserDataToFirestore(user: User, userID: String) async throws {
        do {
            let encodedUser = try Firestore.Encoder().encode(user)
            try await firestore.collection("users").document(userID).setData(encodedUser)
            print("UserDataStoringManager: User data saved/updated successfully for userID: \(userID)")
        } catch {
            throw DataStoringError.savingUserDataFailed(reason: error.localizedDescription)
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
            throw DataStoringError.uploadFailed(reason: error.localizedDescription)
        }
    }
    
    private func decodeUserData(_ data: [String: Any]) throws -> User {
        do {
            return try Firestore.Decoder().decode(User.self, from: data)
        } catch {
            throw DataStoringError.decodingFailed
        }
    }
}
