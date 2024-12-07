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
    
    func login(email: String, password: String) async throws {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            print("Authentication Manager: User signed in succesfully")
        } catch let error as NSError {
            throw error.toAuthenticationError()
        }
    }
    
    func signUp(profileImage: UIImage?, fullName: String, email: String, password: String) async throws {
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            print("Authentication Manager: User signed up with ID: \(authResult.user.uid)")
            
            try await userDataStoringManager.storeUserData(
                userID: authResult.user.uid,
                fullName: fullName,
                email: email,
                profileImage: profileImage
            )
            
            print("Authentication Manager: User data saved successfully")
        } catch let error as NSError {
            throw error.toAuthenticationError()
        }
    }
    
    func signOut() throws {
        try auth.signOut()
        print("Authentication Manager: current userSession: \(String(describing: userSession))")
        print("Authentication Manager: User signed out successfully")
    }
}
