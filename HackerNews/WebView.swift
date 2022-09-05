//
//  WebView.swift
//  HackerNews
//
//  Created by Michael Hsieh on 9/4/22.
//

import SwiftUI
import WebKit

// UIViewRepresentable can create a SwiftUI View that represents a UIKit View
struct WebView: UIViewRepresentable {
    
    let urlString:String?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let safeString = urlString {
            if let safeUrl = URL(string: safeString) {
                let request = URLRequest(url: safeUrl)
                uiView.load(request)
            }
        }
    }
}
