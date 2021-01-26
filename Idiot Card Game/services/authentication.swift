//
//  auth.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/21/20.
//

import Foundation
import FirebaseAuth

class Authentication {
    
    /**
     Log out user from Firebase
     */
    static func logOut() -> Error? {
        do {
            try Auth.auth().signOut()
        } catch {
            return error
        }
        
        return nil
    }
    
    /**
     Get the currently signed in Firebase user
     */
    static func getCurrentUser() -> FirebaseAuth.User? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return currentUser
    }
    
}
