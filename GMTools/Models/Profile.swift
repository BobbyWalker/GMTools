//
//  Profile.swift
//  GMTools
//
//  Created by Bobby Walker on 3/9/25.
//

struct Profile: Codable {
    let username: String?
    let fullName: String?
    let website: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case fullName = "full_name"
        case website
        case avatarURL = "avatar_url"
    }
}
