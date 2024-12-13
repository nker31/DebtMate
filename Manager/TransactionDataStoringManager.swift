//
//  TransactionDataStoringManager.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation
import FirebaseFirestore

protocol TransactionDataStoringManagerProtocol {
    var transactionData: [Transaction] { get }
    func addTransactionData(personID: String, amount: Float, description: String?, dueDate: Date?, isLend: Bool, to userID: String) async throws
    func fetchTransactionData(from userID: String) async throws
    func getNotOverDueTransactionData() -> [Transaction]
    func deleteTransactionData(from transactionID: String, userID: String) async throws
}

class TransactionDataStoringManager: TransactionDataStoringManagerProtocol {
    static let shared = TransactionDataStoringManager()
    
    var transactionData: [Transaction]
    private let firestore: Firestore
    
    private init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
        self.transactionData = []
    }
    
    func addTransactionData(personID: String, amount: Float, description: String?, dueDate: Date?, isLend: Bool, to userID: String) async throws {
        let transaction = createTransactionData(personID: personID, amount: amount, description: description, dueDate: dueDate, isLend: isLend)
        
        do {
            try await storeTransactionData(transaction, to: userID)
        } catch {
            throw error
        }
    }
    
    func fetchTransactionData(from userID: String) async throws {
        let transactionRef = firestore.collection("users").document(userID).collection("transactions")
        
        do {
            let snapshot = try await transactionRef.getDocuments()
            self.transactionData = snapshot.documents.compactMap { doc in
                do {
                    return try Firestore.Decoder().decode(Transaction.self, from: doc.data())
                } catch {
                    return nil
                }
            }
            logMessage("fetched transaction data successfully wiht total : \(transactionData.count)")
        } catch {
            logMessage("failed to fetch transaction data with error: \(error.localizedDescription)")
            throw TransactionError.fetchDataFailed
        }
    }
    
    func deleteTransactionData(from transactionID: String, userID: String) async throws {
        guard let transactionIndex = getTransactionIndex(from: transactionID) else {
            return
        }
        
        transactionData.remove(at: transactionIndex)
        
        let transactionRef = firestore.collection("users")
            .document(userID)
            .collection("transactions")
            .document(transactionID)
        
        do {
            try await transactionRef.delete()
            logMessage("Transaction successfully deleted")
        } catch {
            logMessage("Failed to delete transaction: \(error.localizedDescription)")
            throw TransactionError.dataDeletionFailed
        }
    }
    
    func getNotOverDueTransactionData() -> [Transaction] {
        return transactionData.filter {
            $0.dueDate != nil && $0.isPaid == false && $0.dueDate! > Date()
        }
    }
    
    // MARK: - Private Methods
    private func createTransactionData(personID: String, amount: Float, description: String?, dueDate: Date?, isLend: Bool) -> Transaction {
        let description = description == "" ? nil : description
        let transaction = Transaction(personID: personID,
                                      amount: amount,
                                      isLend: isLend,
                                      description: description,
                                      dueDate: dueDate)
        return transaction
    }
    
    private func storeTransactionData(_ transaction: Transaction, to userID: String) async throws {
        let transactionRef = firestore.collection("users").document(userID).collection("transactions").document(transaction.transactionID)
        
        transactionData.append(transaction)
        
        do {
            try transactionRef.setData(from: transaction)
            logMessage("storing transaction data successful")
        } catch {
            logMessage("storing transaction data failed with error: \(error.localizedDescription)")
            throw DataStoringError.savingUserDataFailed
        }
    }
    
    private func getTransactionIndex(from transactionID: String) -> Int? {
        return transactionData.firstIndex { $0.transactionID == transactionID }
    }
    
    private func getTransactionData(from transactionID: String) -> Transaction? {
        return transactionData.first { $0.transactionID == transactionID }
    }
    
    private func logMessage(_ message: String) {
        print("TransactionDataStoringManager: \(message)")
    }
}
