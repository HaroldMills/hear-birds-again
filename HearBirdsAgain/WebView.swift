//
//  WebView.swift
//  HearBirdsAgain
//
//  Created by Harold Mills on 9/26/22.
//


import SwiftUI
import WebKit
 

struct WebView: UIViewRepresentable {
 
    
    var url: URL
 
    
    func makeUIView(context: Context) -> WKWebView {
        
        let view = WKWebView()
        
        // Make WKWebView background transparent.
        view.isOpaque = false
        view.backgroundColor = UIColor.clear
        view.scrollView.backgroundColor = UIColor.clear
        
        return view
        
    }
 
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    
}
