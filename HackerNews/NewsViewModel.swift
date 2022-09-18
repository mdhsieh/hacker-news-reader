//
//  NewsModel.swift
//  HackerNews
//
//  Created by Matteo Manferdini on 21/10/2020.
//

import Foundation

class NewsViewModel: ObservableObject {
	@Published var stories: [Item?] = Array(repeating: nil, count: 100)
	
    func fetchStories(filteredBy:String) {
        var url:URL
        if (filteredBy == "top") {
            url = URL(string: "https://hacker-news.firebaseio.com/v0/beststories.json")!
        } else {
            url = URL(string: "https://hacker-news.firebaseio.com/v0/newstories.json")!
        }
        let request = APIRequest(url: url)
        request.perform { [weak self] (ids: [Int]?) -> Void in
            guard let ids = ids?.prefix(100) else { return }
            for (index, id) in ids.enumerated() {
                self?.fetchStory(withID: id) { story in
                    self?.stories[index] = story
                }
            }
        }
    }
	
	func fetchStory(withID id: Int, completion: @escaping (Item?) -> Void) {
		let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
		let request = APIRequest(url: url)
		request.perform(with: completion)
	}
}
