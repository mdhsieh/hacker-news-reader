//
//  DetailView.swift
//  HackerNews
//
//  Created by Michael Hsieh on 9/4/22.
//

import SwiftUI
import Firebase
import CoreData

struct DetailView: View {
    let url:String?

    // Not nil if coming from browse news list
    let story:Item?
    // Not nil if coming from favorites list
    // State because is assigned Core Data item if story matches
    @State var favoriteNews:FavoriteItem?
    // Decides whether toolbar heart button should be filled or not
    // because button does not update if favoriteNews changes
    @State var isFavorite: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    
    @Environment(\.openURL) var openURL
    
    @State private var showingComments = false
    
    // Return array of 1 CoreData favorite item if
    // matches story,
    // otherwise returns empty array
    private func getMatchingFavoriteItem(title: String, author: String) -> [FavoriteItem] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteItem")
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND author == %@", title, author)
        fetchRequest.fetchLimit = 1

        do {
            let favoriteResult = try moc.fetch(fetchRequest) as? [FavoriteItem] ?? []
            return favoriteResult
            
          } catch let error as NSError {
              print("Could not fetch. \(error.localizedDescription)")
              return []
          }
    }
    
    var body: some View {
        WebView(urlString: url)
            .onAppear {
                FirebaseAnalytics.Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterScreenName: "web view",
                    "url": url ?? "Unknown URL"
                ])
                
                if favoriteNews != nil {
                    isFavorite = true
                }
                
                // Article is from browse news list but
                // has already been saved to favorites
                if let story = story {
                    let matchingFavoriteNewsArr = getMatchingFavoriteItem(title: story.title, author: story.author)
                    if matchingFavoriteNewsArr.count > 0 {
                        favoriteNews = matchingFavoriteNewsArr[0]
                        isFavorite = true
                    }
                }
                
            }
            .toolbar {
                Button {
                    showingComments = true
                } label: {
                    Image(systemName: "bubble.right")
                }
                
                Button {
                    openURL(URL(string: url!)!)
                } label: {
                    Image(systemName: "safari")
                }
                
                if isFavorite {
                    // Article from favorites list or
                    // Article from browse news lists matches an item in favorites list
                    Button(
                       action: {
                           if let favoriteNews = favoriteNews {
                               // delete it from the context
                               moc.delete(favoriteNews)
                               
                               // save the context
                               try? moc.save()
                               
                               isFavorite = false
                           }
                       },
                       label: {
                           Image(systemName: "heart.fill")
                       }
                   )
                } else {
                    // Article from browse news list
                    Button(
                        action: {
                            if let story = story {
                            
                                // save article
                                let favorite = FavoriteItem(context: moc)
                                favorite.id = UUID()
                                favorite.title = story.title
                                favorite.author = story.author
                                favorite.score = Int64(story.score)
                                favorite.commentCount = Int64(story.commentCount)
                                favorite.url = story.url
                                favorite.date = story.date
                                
                                favorite.storyId = Int64(story.id)

                                if let kids = story.kids {
                                    favorite.kids = kids as NSObject as? [Int]
                                } else {
                                    favorite.kids = []
                                }
                                
                                try? moc.save()
                            
                                isFavorite = true
                            }
                        },
                        label: {
                            Image(systemName: "heart")
                        }
                    )
                }
            }.sheet(isPresented: $showingComments) {
                if let story = story {
                    CommentsView(commentIds: story.kids ?? [])
                } else {
                    if let favoriteNews = favoriteNews {
                        CommentsView(commentIds: favoriteNews.kids ?? [])
                    }
                }
            }
    }
}
struct CommentsView: View {
    @Environment(\.dismiss) private var dismiss
    var commentIds: [Int]
    @StateObject private var commentsModel = CommentsViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .padding()
                }
            }
            
            ScrollView {
                ForEach(commentsModel.comments, id:\.self) { comment in
                    if let comment = comment {
                        VStack {
                            Text("\(comment.author) \(comment.date.timeAgo)")
                            HTMLStringView(htmlContent: comment.text)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 150, maxHeight: .infinity)
                        }
                        .padding()
                        
                       Divider()
                    }
                }
            }
        }
        .onAppear {
            commentsModel.fetchComments(ids: commentIds)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(url: "https://www.google.com", story: nil, favoriteNews: nil)
    }
}
