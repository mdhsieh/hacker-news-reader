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
                if isFavorite {
                    Button {
                        if let favoriteNews = favoriteNews {
                            openURL(favoriteNews.url!)
                        }
                    } label: {
                        Image(systemName: "safari")
                    }
                    
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
                    Button {
                        if let story = story {
                            openURL(story.url)
                        }
                    } label: {
                        Image(systemName: "safari")
                    }
                    
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
                                
                                try? moc.save()
                            
                                isFavorite = true
                            }
                        },
                        label: {
                            Image(systemName: "heart")
                        }
                    )
                }
            }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(url: "https://www.google.com", story: nil, favoriteNews: nil)
    }
}
