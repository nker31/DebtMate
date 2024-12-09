//
//  AuthenticationManager.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationManagerProtocol {
    var userSession: FirebaseAuth.User? { get }
    func login(email: String, password: String) async throws
    func signUp(profileImage: UIImage?, fullName: String, email: String, password: String) async throws
    func changePassword(oldPassword: String, newPassword: String) async throws
    func signOut() throws
}

final class AuthenticationManager: AuthenticationManagerProtocol {
    static let shared = AuthenticationManager()
    
    private let auth: Auth
    private let firestore: Firestore
    private let userDataStoringManager: UserDataStoringManagerProtocol
    var userSession: FirebaseAuth.User? {
        auth.currentUser
    }
    
    private init(auth: Auth = Auth.auth(),
                 firestore: Firestore = Firestore.firestore(),
                 userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.auth = auth
        self.firestore = firestore
        self.userDataStoringManager = userDataStoringManager
        print("AuthenticationManager initialized with user ID: \(String(describing: userSession?.uid))")
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            logMessage("User logged in succesfully")
        } catch let error as NSError {
            logMessage("failed to log in with error \(error.localizedDescription)")
            throw error.toAuthenticationError()
        }
    }
    
    // MARK: - Sign Up
    func signUp(profileImage: UIImage?, fullName: String, email: String, password: String) async throws {
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            logMessage("User signed up with ID: \(authResult.user.uid)")
            
            try await userDataStoringManager.storeUserData(
                userID: authResult.user.uid,
                fullName: fullName,
                email: email,
                profileImage: profileImage
            )
            
            logMessage("User data saved successfully")
        } catch let error as NSError {
            logMessage("failed to sign up with error \(error.localizedDescription)")
            throw error.toAuthenticationError()
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try auth.signOut()
        logMessage("User signed out successfully, current userSession: \(String(describing: userSession))")
    }
    
    // MARK: - Change Password
    func changePassword(oldPassword: String, newPassword: String) async throws {
        guard let email = userSession?.email,
        let user = auth.currentUser else {
            logMessage("no current user signed in")
            throw AuthenticationError.userNotFound
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        
        try await reAuthenticate(user: user, with: credential)
        
        do {
            try await user.updatePassword(to: newPassword)
            logMessage("Updated password successfully")
        } catch {
            logMessage("failed to update password with error \(error.localizedDescription)")
            throw AuthenticationError.passwordUpdateFailed
        }
    }
    
    // MARK: - Private Method
    private func reAuthenticate(user: FirebaseAuth.User, with credential: AuthCredential) async throws {
        do {
            try await user.reauthenticate(with: credential)
        } catch let error as NSError {
            logMessage("failed to reauthenticate user with error \(error.localizedDescription)")
            throw error.toAuthenticationError()
        }
    }
    
    private func logMessage(_ message: String) {
        print("Authentication Manager: \(message)")
    }
}
