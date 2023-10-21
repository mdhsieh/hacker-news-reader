//
//  Item.swift
//  HackerNews
//
//  Created by Matteo Manferdini on 15/10/2020.
//

import Foundation

// Equatable in order to compare during search. Hashable in order to show in ForEach to do filtering
struct Item: Identifiable, Equatable, Hashable {
	let id: Int
	let commentCount: Int
	let score: Int
	let author: String
	let title: String
	let date: Date
	let url: URL
    let kids: [Int]?
}

extension Item: Decodable {
	enum CodingKeys: String, CodingKey {
		case id, score, title, url, kids
		case commentCount = "descendants"
		case date = "time"
		case author = "by"
	}
}
