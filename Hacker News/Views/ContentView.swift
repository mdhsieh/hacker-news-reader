//
//  ContentView.swift
//  Hacker News
//
//  Created by Michael Hsieh on 5/29/22.
//

import SwiftUI

struct ContentView: View {
    
    // Set up this property as a listener. In this way we
    // subscribe to updates from the NetworkManager
    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            // Use published property
            List(networkManager.posts, rowContent: { post in
                
                NavigationLink(destination: DetailView(url: post.url)) {
                    HStack {
                        Text(String(post.points))
                        Text(post.title)
                    }
                }
                
                
            })
            .navigationBarTitle("Hacker News")
        }
        .onAppear {
            self.networkManager.fetchData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




//let posts = [
//    Post(id: "1", title: "Hello"),
//    Post(id: "2", title: "Hola"),
//    Post(id: "3", title: "Bonjour"),
//]
