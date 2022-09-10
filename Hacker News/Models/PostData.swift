//
//  PostData.swift
//  Hacker News
//
//  Created by Michael Hsieh on 5/29/22.
//

import Foundation

struct Results: Decodable {
    let hits: [Post]
}

// Conform to Identifiable protocol
// to allow list to recognize order of
// Post objects based on ID
struct Post: Decodable, Identifiable {
    // Identifiable protocol requires property to be called, "id"
    // But already have an ID from API.
    // Use computed property to convert as objectID
    var id:String {
        return objectID
    }
    let objectID:String
    let title:String
    let points:Int
    // Allow to be null in certain cases
    let url:String?
}


