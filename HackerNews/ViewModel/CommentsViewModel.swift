//
//  CommentsViewModel.swift
//  HN Reader
//
//  Created by Michael Hsieh on 10/18/23.
//

import Foundation
import SwiftUI

class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment?] = Array(repeating: nil, count: Constants.ITEM_COUNT)
    
    func fetchComments(ids: [Int]) {
        for (index, id) in ids.enumerated() {
            self.fetchComment(withID: id) { comment in
                self.comments.append(comment)
            }
        }
    }
    
    func fetchComment(withID id: Int, completion: @escaping (Comment?) -> Void) {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
        let request = APIRequest(url: url)
        request.perform(with: completion)
    }
}
