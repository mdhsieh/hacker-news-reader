//
//  NewsModel.swift
//  HackerNews
//
//  Created by Matteo Manferdini on 21/10/2020.
//

import Foundation
import SwiftUI

class NewsViewModel: ObservableObject {
	@Published var stories: [Item?] = Array(repeating: nil, count: 250)
    @Published var searchText:String = ""
    
    // Nav bar sort options
    @AppStorage("filterQuery") var filterQuery = "top"
    @Published var filters = ["top", "newest"]
    
    enum ResultState {
        case loading
        case success
//        case failed
    }

    @Published var resultState: ResultState = .loading
	
    func fetchStories(filteredBy:String) {
        var url:URL
        if (filteredBy == "top") {
            url = URL(string: "https://hacker-news.firebaseio.com/v0/beststories.json")!
        } else {
            url = URL(string: "https://hacker-news.firebaseio.com/v0/newstories.json")!
        }
        let request = APIRequest(url: url)
        request.perform { [weak self] (ids: [Int]?) -> Void in
            guard let ids = ids?.prefix(250) else { return }
            for (index, id) in ids.enumerated() {
                self?.fetchStory(withID: id) { story in
                    self?.stories[index] = story
                }
            }
            
            // Finished loading
            self?.resultState = .success
        }
    }
	
	func fetchStory(withID id: Int, completion: @escaping (Item?) -> Void) {
		let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
		let request = APIRequest(url: url)
		request.perform(with: completion)
	}
    
    var filteredStories: [Item?] {
        // If search is empty, return the whole list since there's no filters
        if (searchText == "") {
            return stories
        } else {
            return stories.filter( { story -> Bool in
                if let unwrappedStory = story {
                    return unwrappedStory.title.lowercased().contains(searchText.lowercased())
                }
                return false
            } )
        }
    }
}
