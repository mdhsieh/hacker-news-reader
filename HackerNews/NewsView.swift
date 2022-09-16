//
//  NewsView.swift
//  HackerNews
//
//  Created by Matteo Manferdini on 15/10/2020.
//

import SwiftUI

struct NewsView: View {
	@StateObject private var model = NewsViewModel()
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        // SortDescriptor(\.title),
        SortDescriptor(\.date)
    ]) var favorites: FetchedResults<FavoriteItem>
	
	var body: some View {
        
        TabView {
            NavigationView {
                List(model.stories.indices) { index in
                    if let story = model.stories[index] {
                        Story(position: index + 1, item: story)
                            .contextMenu {
                                Button(
                                    action: {
                                        // save article
                                        let favorite = FavoriteItem(context: moc)
                                        favorite.id = UUID()
                                        favorite.title = story.title
                                        favorite.author = story.author
                                        favorite.score = Int64(story.score)
                                        favorite.commentCount = Int64(story.commentCount)
                                        favorite.url = story.url.absoluteString
                                        favorite.date = story.date
                                        
                                        try? moc.save()
                                    },
                                    label: {
                                        Text("Add to favorites")
                                        Image(systemName: "heart.fill")
                                    }
                                )
                             
                            }
                    }
                }
                .navigationTitle("News")
                .onAppear(perform: model.fetchTopStories)
                
            }
            .refreshable {
                model.fetchTopStories()
            }
            .tabItem {
                Label("News", systemImage: "newspaper")
            }

            NavigationView {
                List(favorites) { favoriteNews in
                    FavoriteStory(favorite: favoriteNews)
                }
                .navigationTitle("Favorites")
            }.tabItem {
                Label("Favorites", systemImage: "heart")
            }
        }
	}
}

// MARK: - Story
struct Story: View {
	let position: Int
	let title: String
	let footnote: String
	let score: String
	let commentCount: String
    let url:String
	
	var body: some View {
        NavigationLink(destination: DetailView(url: url)) {
            HStack(alignment: .top, spacing: 16.0) {
                Position(position: position)
                VStack(alignment: .leading, spacing: 8.0) {
                    Text(title)
                        .font(.headline)
                    Text(footnote)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                        Badge(text: score, imageName: "arrowtriangle.up.circle")
                            .foregroundColor(.teal)
                    }
                    .font(.callout)
                    .padding(.bottom)
                }
            }
            .padding(.top, 16.0)
        }
	}
}

extension Story {
	init(position: Int, item: Item) {
		self.position = position
		title = item.title
		score = item.score.formatted
		commentCount = item.commentCount.formatted
		footnote = item.url.formatted
			+ " - \(item.date.timeAgo)"
			+ " - by \(item.author)"
        self.url = item.url.absoluteString
	}
}

struct Badge: View {
	let text: String
	let imageName: String
	
	var body: some View {
		HStack {
			Image(systemName: imageName)
			Text(text)
		}
	}
}

struct Position: View {
	let position: Int
	
	var body: some View {
		ZStack {
			Circle()
				.frame(width: 32.0, height: 32.0)
				.foregroundColor(.teal)
			Text("\(position)")
				.font(.callout)
				.bold()
				.foregroundColor(.white)
		}
	}
}

struct NewsView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			Story(position: 1, item: TestData.story)
			Position(position: 1)
			Badge(text: "1.234", imageName: "paperplane")
		}
		.previewLayout(.sizeThatFits)
	}
}

struct FavoriteStory: View {
    
    var favorite: FavoriteItem
    
    var body: some View {
        NavigationLink(destination: DetailView(url: favorite.url)) {
            HStack(alignment: .top, spacing: 16.0) {
                VStack(alignment: .leading, spacing: 8.0) {
                    Text(favorite.title ?? "Unknown")
                        .font(.headline)
                    Text(favorite.url ?? ""
                         + " - \(favorite.date?.timeAgo ?? "Unknown")"
                         + " - by \(favorite.author ?? "Unknown")")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                        Badge(text: String(favorite.score), imageName: "arrowtriangle.up.circle")
                            .foregroundColor(.teal)
                    }
                    .font(.callout)
                    .padding(.bottom)
                }
            }
            .padding(.top, 16.0)
        }
    }
}
