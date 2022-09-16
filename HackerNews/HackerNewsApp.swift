//
//  HackerNewsApp.swift
//  HackerNews
//
//  Created by Matteo Manferdini on 15/10/2020.
//

import SwiftUI

@main
struct HackerNewsApp: App {
    
    @StateObject private var dataController = DataController()
    
	var body: some Scene {
		WindowGroup {
            NewsView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
		}
	}
}
