//
//  HackerNewsApp.swift
//  HackerNews
//
//  Created by Matteo Manferdini on 15/10/2020.
//

import SwiftUI
import Firebase

@main
struct HackerNewsApp: App {
    
    @StateObject private var dataController = DataController()
    
    init() {
      FirebaseApp.configure()
    }
    
	var body: some Scene {
		WindowGroup {
            NewsView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
		}
	}
}
