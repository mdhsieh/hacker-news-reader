//
//  NewsView.swift
//  HackerNews
//
//  Created by Matteo Manferdini on 15/10/2020.
//

import SwiftUI
// Only for item exists function
import CoreData

struct NewsView: View {
	@StateObject private var model = NewsViewModel()
    
    @Environment(\.managedObjectContext) var moc
    // Fetch favorites by latest date first, in order to match fetched latest news order
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date, order: .reverse)
    ]) var favorites: FetchedResults<FavoriteItem>
    
    // Nav bar sort options
    @AppStorage("filterQuery") private var filterQuery = "top"
    let filters = ["top", "newest"]

	var body: some View {
        
        TabView {
            NavigationView {
                // Get both the index and the Item? in order to show position number
                // Need id because the (index, Item?) pair is not Identifiable
                let filteredStoriesIndexed = model.filteredStories.enumerated().map({ $0 })
                VStack {
                    switch model.resultState {
                    case .loading:
                        ProgressView().progressViewStyle(CircularProgressViewStyle()).scaleEffect(3).tint(.teal)
                    case .success:
                        BrowseNewsView(model: model, filteredStoriesIndexed: filteredStoriesIndexed)
                    }
                }
                    .navigationTitle("News")
                    .searchable(text: $model.searchText)
                    .toolbar {
                        // Filter by new or top stories
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Picker("", selection: $filterQuery) {
                                    ForEach(filters, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .onChange(of: filterQuery) { newValue in
                                    model.fetchStories(filteredBy: newValue)
                                }
                            } label: {
                                HStack {
                                    Text("Sort by: \(filterQuery)")
                                        .font(.callout)
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                }
                            }
                        }
                    }
                    .onAppear {
                        model.fetchStories(filteredBy: filterQuery)
                        
                        // remove the notification badge after open app
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        
                        if (NotificationManager.instance.shouldScheduleNotifications) {
                            NotificationManager.instance.requestNotification()
                        } else {
                            print("Notifications are already scheduled")
                        }
                    }
                
            }
            .refreshable {
                model.fetchStories(filteredBy: filterQuery)
            }
            .tabItem {
                Label("News", systemImage: "newspaper")
            }

            NavigationView {
                List(favorites) { favoriteNews in
                    FavoriteStory(favorite: favoriteNews)
                        .contextMenu {
                            Button(
                                action: {
                                    // delete it from the context
                                    moc.delete(favoriteNews)
                                    
                                    // save the context
                                    try? moc.save()
                                },
                                label: {
                                    Text("Remove from favorites")
                                    Image(systemName: "heart.slash")
                                }
                            )
                         
                        }
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
    let urlStr:String
	
	var body: some View {
        NavigationLink(destination: DetailView(url: urlStr)) {
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
        self.urlStr = item.url.absoluteString
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
        NavigationLink(destination: DetailView(url: favorite.url?.absoluteString)) {
            HStack(alignment: .top, spacing: 16.0) {
                VStack(alignment: .leading, spacing: 8.0) {
                    Text(favorite.title ?? "Unknown")
                        .font(.headline)
                    Text(favorite.url?.formatted ?? ""
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

struct BrowseNewsView: View {
    
    @Environment(\.managedObjectContext) var moc

    @ObservedObject var model: NewsViewModel
    var filteredStoriesIndexed: [EnumeratedSequence<[Item?]>.Element]
    
    private func itemExists(title: String, author: String) -> Bool {
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteItem")
       fetchRequest.predicate = NSPredicate(format: "title == %@ AND author == %@", title, author)
       return ((try? moc.count(for: fetchRequest)) ?? 0) > 0
    }
    
    var body: some View {
        List(filteredStoriesIndexed, id: \.element) { index, filteredStory in
            if let story = filteredStory {
                Story(position: index + 1, item: story)
                    .contextMenu {
                        if (itemExists(title: story.title, author: story.author)) {
                            Button(
                                action: {
                                    // No action
                                },
                                label: {
                                    Text("Added to favorites")
                                    Image(systemName: "heart.fill")
                                }
                            )
                        } else {
                            Button(
                                action: {
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
                                },
                                label: {
                                    Text("Add to favorites")
                                    Image(systemName: "heart")
                                }
                            )
                        }
                    }
            }
        }
        
    }
}
