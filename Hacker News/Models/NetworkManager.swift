//
//  NetworkManager.swift
//  Hacker News
//
//  Created by Michael Hsieh on 5/29/22.
//

import Foundation

// protocol ObservableObject is to broadcast one or many of its properties
// to interested parties. In this case send data to ContentView
class NetworkManager: ObservableObject {
    
    // property which will be published.
    // Whenever it has changes, notify its listeners
    @Published var posts = [Post]()
    
    func fetchData() {
        if let url = URL(string: "http://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=100") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if (error == nil) {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(Results.self, from: safeData)
                            // Happen on main thread not background
                            DispatchQueue.main.async {
                                self.posts = results.hits
                            }
                        } catch {
                            print(error)
                        }
                        
                    }
                }
            }
            task.resume()
        }
    }
}
