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
    func login(email: String, password: String) async throws
    func signUp(profileImage: UIImage?, fullName: String, email: String, password: String) async throws
    func signOut() throws
}

final class AuthenticationManager: AuthenticationManagerProtocol {
    static let shared = AuthenticationManager()
    
    private let auth: Auth
    private let firestore: Firestore
    private let userDataStoringManager: UserDataStoringManagerProtocol
    private var userSession: FirebaseAuth.User?
    private(set) var currentUser: User?
    
    private init(auth: Auth = Auth.auth(),
                 firestore: Firestore = Firestore.firestore(),
                 userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.auth = auth
        self.firestore = firestore
        self.userDataStoringManager = userDataStoringManager
        self.userSession = auth.currentUser
        print("AuthenticationManager initialized with user ID: \(String(describing: userSession?.uid))")
    }
    
    func login(email: String, password: String) async throws {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        let user = authResult.user
        print("Authentication Manager: User signed in with ID: \(user.uid)")
        
        self.currentUser = try await userDataStoringManager.fetchUserData(userID: user.uid)
        print("Authentication Manager: Current User = \(String(describing: currentUser))")
    }
    
    func signUp(profileImage: UIImage?, fullName: String, email: String, password: String) async throws {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let user = authResult.user
        print("Authentication Manager: User signed up with ID: \(user.uid)")
        
        try await userDataStoringManager.storeUserData(
            userID: user.uid,
            fullName: fullName,
            email: email,
            profileImage: profileImage
        )
        
        self.currentUser = try await userDataStoringManager.fetchUserData(userID: user.uid)
        print("Authentication Manager: User data saved successfully for ID: \(user.uid)")
    }
    
    func signOut() throws {
        try auth.signOut()
        self.userSession = nil
        self.currentUser = nil
        print("Authentication Manager: User signed out successfully")
    }
}
