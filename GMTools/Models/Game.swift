//
//  Game.swift
//  GMTools
//
//  Created by Bobby Walker on 3/12/25.
//

import Foundation

struct Game {
    let ID: Int
    let name: String
    let owner: UUID
    let systems: [System]
    let players: [Profile] // Characters would be better served here...
    let logs: [String] // Experience point log
}
