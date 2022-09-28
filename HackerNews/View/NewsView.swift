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
    
    @State var selectedColor: Color = .teal
    private var colorData = ColorData()
    
	var body: some View {
        
        TabView {
            NavigationView {
                // Get both the index and the Item? in order to show position number
                let filteredStoriesIndexed = model.filteredStories.enumerated().map({ $0 })
                VStack {
                    CustomColorPicker(selectedColor: $selectedColor, colorData: colorData)
                    
                    switch model.resultState {
                    case .loading:
                        ProgressView().progressViewStyle(CircularProgressViewStyle()).scaleEffect(3).tint(selectedColor)
                    case .success:
                        BrowseNewsView(model: model, filteredStoriesIndexed: filteredStoriesIndexed, selectedColor: selectedColor)
                    }
                }
                .navigationTitle("News")
                .searchable(text: $model.searchText, placement: .navigationBarDrawer(displayMode: .always))
                .toolbar {
                    // Filter by new or top stories
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Picker("", selection: $model.filterQuery) {
                                ForEach(model.filters, id: \.self) {
                                    Text($0)
                                }
                            }
                            .onChange(of: model.filterQuery) { newValue in
                                model.fetchStories(filteredBy: newValue)
                            }
                        } label: {
                            HStack {
                                Text("Sort by: \(model.filterQuery)")
                                    .font(.callout)
                                Image(systemName: "line.3.horizontal.decrease.circle")
                            }
                        }
                    }
                }
                .onAppear {
                    model.fetchStories(filteredBy: model.filterQuery)
                    
                    // remove the notification badge after open app
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    
                    // schedule daily notification if not scheduled already
                    if (NotificationManager.instance.shouldScheduleNotifications) {
                        NotificationManager.instance.requestNotification()
                    }
                    
                    // Change selected color to whatever was saved in
                    // user defaults
                    selectedColor = colorData.loadColor()
                }
                
            }
            .refreshable {
                model.fetchStories(filteredBy: model.filterQuery)
            }
            .tabItem {
                Label("News", systemImage: "newspaper")
            }

            NavigationView {
                FavoritesView(selectedColor: selectedColor)
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
    let selectedColor: Color
	
	var body: some View {
        NavigationLink(destination: DetailView(url: urlStr)) {
            HStack(alignment: .top, spacing: 16.0) {
                Position(position: position, selectedColor: selectedColor)
                VStack(alignment: .leading, spacing: 8.0) {
                    Text(title)
                        .font(.headline)
                    Text(footnote)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                        Badge(text: score, imageName: "arrowtriangle.up.circle")
                            .foregroundColor(selectedColor)
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
    init(position: Int, item: Item, selectedColor: Color) {
		self.position = position
		title = item.title
		score = item.score.formatted
		commentCount = item.commentCount.formatted
		footnote = item.url.formatted
			+ " - \(item.date.timeAgo)"
			+ " - by \(item.author)"
        self.urlStr = item.url.absoluteString
        self.selectedColor = selectedColor
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
    let selectedColor: Color
	
	var body: some View {
		ZStack {
			Circle()
				.frame(width: 32.0, height: 32.0)
				.foregroundColor(selectedColor)
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
            Story(position: 1, item: TestData.story, selectedColor: .teal)
            Position(position: 1, selectedColor: .teal)
			Badge(text: "1.234", imageName: "paperplane")
		}
		.previewLayout(.sizeThatFits)
	}
}

struct FavoriteStory: View {
    
    var favorite: FavoriteItem
    var selectedColor: Color
    
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
                            .foregroundColor(selectedColor)
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
    
    var selectedColor: Color
    
    private func itemExists(title: String, author: String) -> Bool {
       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteItem")
       fetchRequest.predicate = NSPredicate(format: "title == %@ AND author == %@", title, author)
       return ((try? moc.count(for: fetchRequest)) ?? 0) > 0
    }
    
    // Need id because the (index, Item?) pair is not Identifiable
    var body: some View {
        List(filteredStoriesIndexed, id: \.element) { index, filteredStory in
            if let story = filteredStory {
                Story(position: index + 1, item: story, selectedColor: selectedColor)
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

struct FavoritesView: View {
    @Environment(\.managedObjectContext) var moc
    var selectedColor: Color
    
    // Fetch favorites by latest date first, in order to match fetched latest news order
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date, order: .reverse)
    ]) var favorites: FetchedResults<FavoriteItem>
    
    @State private var searchText = ""
    
    private func searchPredicate(query: String) -> NSPredicate? {
      if query.isEmpty {
          return nil
          
      }
        return NSPredicate(format: "title CONTAINS[cd] %@", query.lowercased())
    }
    
    var body: some View {
        List(favorites) { favoriteNews in
            FavoriteStory(favorite: favoriteNews, selectedColor: selectedColor)
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: searchText) { newValue in
          favorites.nsPredicate = searchPredicate(query: newValue)
        }
    }
}
