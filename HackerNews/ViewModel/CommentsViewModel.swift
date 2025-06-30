//
//  CommentsViewModel.swift
//  HN Reader
//
//  Created by Michael Hsieh on 10/18/23.
//

import Foundation
import SwiftUI

class CommentsViewModel: ObservableObject {
    @Published var comments: [CommentNode] = []

    func fetchComments(ids: [Int]) {
        for id in ids {
            fetchComment(withID: id) { comment in
                if let comment = comment {
                    DispatchQueue.main.async {
                        self.comments.append(CommentNode(comment: comment))
                    }
                }
            }
        }
    }

    func fetchChildComments(for node: CommentNode) {
        for id in node.comment.kids {
            fetchComment(withID: id) { comment in
                if let comment = comment {
                    DispatchQueue.main.async {
                        let childNode = CommentNode(comment: comment)
                        node.children.append(childNode)
                    }
                }
            }
        }
    }

    
    func fetchComment(withID id: Int, completion: @escaping (Comment?) -> Void) {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
        let request = APIRequest(url: url)
        request.perform(with: completion)
    }
}

class CommentNode: ObservableObject, Identifiable {
    let id: Int
    let comment: Comment
    @Published var isExpanded: Bool = false
    @Published var children: [CommentNode] = []
    
    init(comment: Comment) {
        self.comment = comment
        self.id = comment.id
    }
}
