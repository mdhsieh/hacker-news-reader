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
    var finishedLoading: Binding<Bool>
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        // return WKWebView()
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let safeString = urlString {
            if let safeUrl = URL(string: safeString) {
                let request = URLRequest(url: safeUrl)
                uiView.load(request)
            }
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if (webView.isLoading) {
                   return
            }
            print("Done Loading")
            self.parent.finishedLoading.wrappedValue = true
        }
    }
}
