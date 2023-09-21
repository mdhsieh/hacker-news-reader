//
//  DetailView.swift
//  HackerNews
//
//  Created by Michael Hsieh on 9/4/22.
//

import SwiftUI
import Firebase

struct DetailView: View {
    let url:String?
    
    var body: some View {
            
        ZStack {
            WebView(urlString: url)
                .onAppear {
                    FirebaseAnalytics.Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterScreenName: "web view",
                        "url": url ?? "Unknown URL"
                    ])
                }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(url: "https://www.google.com")
    }
}
