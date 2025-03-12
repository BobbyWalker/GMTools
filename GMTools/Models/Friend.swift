//
//  Friend.swift
//  GMTools
//
//  Created by Bobby Walker on 3/12/25.
//

import Foundation

struct Friend: Codable {
    let owner: UUID
    let profile: Profile
    let requestedBy: UUID
    let requestSent: Date
    let requestAccepted: Date?
    let favorite: Bool
    
    enum CodingKeys: CodingKey {
        case owner
        case profile
        case requestedBy
        case requestSent
        case requestAccepted
        case favorite
    }
}
