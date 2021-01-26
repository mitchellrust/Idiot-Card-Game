//
//  Game.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/8/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Game: Codable {
    @DocumentID var id: String?
    var code: Int = -1
    @ServerTimestamp var createDate: Date?
    var finished: Bool = false
    var player1: Player = Player()
    var player2: Player = Player()
    var player3: Player = Player()
    var player4: Player = Player()
    var podium: [String] = []
    let deckOrder: [Int]
}

struct Player: Codable, Equatable {
    var id: String = ""
    var hand: [Int] = []
}

