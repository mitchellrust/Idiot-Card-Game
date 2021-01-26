//
//  User.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/2021.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    let id: String
    var displayName: String
    let email: String
    var profilePhotoUrl: String = ""
}
