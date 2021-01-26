//
//  firestore.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/2021.
//

import Foundation
import FirebaseFirestore

class CloudFS {
        
    /*
     Create a new user document in Firestore
     */
    static func createUser(user: User, completion: @escaping (Error?) -> Void) {
        do {
            let userDoc = Firestore.firestore().collection("users").document(user.id)
            try userDoc.setData(from: user)
        }
        catch {
            completion(error)
        }
        completion(nil)
    }
    
    /*
     Update a user document in Firestore
     */
    static func updateUser(docId: String, data: [String : Any], completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("users").document(docId).updateData(data) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    /*
     Listen to a user document from Firestore
     */
    static func getUser(docId: String, completion: @escaping (User?) -> Void) {
        Firestore.firestore().collection("users").document(docId).addSnapshotListener { (documentSnapshot, error) in
            guard documentSnapshot != nil && documentSnapshot!.exists else {
                print("Could not find user \(docId)")
                completion(nil)
                return
            }
            let user = try? documentSnapshot!.data(as: User.self)
            completion(user)
        }
    }
    
    /*
     Create a new game document in Firestore
     */
    static func createGame(game: Game, completion: @escaping (String?) -> Void) {
        do {
            let doc = try Firestore.firestore().collection("games").addDocument(from: game)
            completion(doc.documentID)
        }
        catch {
            completion(nil)
        }
    }
    
    /*
     Update a game document in Firestore
     */
    static func updateGame(docId: String, data: [String : Any], completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("games").document(docId).updateData(data) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    /*
     Delete a game document from Firestore
     */
    static func deleteGame(docId: String) {
        Firestore.firestore().collection("games").document(docId).delete() { error in
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
    
    /*
     Listen to a game document from Firestore
     */
    static func getGame(docId: String, completion: @escaping (Game?) -> Void) {
        Firestore.firestore().collection("games").document(docId).addSnapshotListener { (documentSnapshot, error) in
            guard documentSnapshot != nil && documentSnapshot!.exists else {
                print("Could not find game \(docId)")
                completion(nil)
                return
            }
            let game = try? documentSnapshot!.data(as: Game.self)
            completion(game)
        }
    }
    
    /*
     Find a game using Firestore query.
     */
    static func queryForGameId(query: Query, completion: @escaping (String?) -> Void) {
        query.getDocuments { (querySnapshot, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            if querySnapshot!.documents.count > 0 {
                let game = try? querySnapshot!.documents[0].data(as: Game.self)
                guard game != nil else {
                    completion(nil)
                    return
                }
                completion(game!.id)
            } else {
                completion(nil)
            }
        }
    }
    
    /*
     Create a new support document in Firestore
     */
    static func sendSupportDocument(data: Dictionary<String, Any>, completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("support").document().setData(data) { error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
}
