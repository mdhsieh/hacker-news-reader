//
//  Comment.swift
//  HN Reader
//
//  Created by Michael Hsieh on 10/18/23.
//

import Foundation

struct Comment: Identifiable, Hashable {
    let id: Int
    let author: String
    let kids: [Int]
    let parent: Int
    let text: String
    let date: Date
}

extension Comment: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, kids, parent, text
        case date = "time"
        case author = "by"
    }
}
