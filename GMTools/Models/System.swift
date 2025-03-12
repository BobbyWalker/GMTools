//
//  System.swift
//  GMTools
//
//  Created by Bobby Walker on 3/12/25.
//

import Foundation

struct System: Codable {
    var id: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
