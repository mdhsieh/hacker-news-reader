//
//  ActivityViewController.swift
//  HN Reader
//
//  Created by Алексей Воронов on 02.02.2020.
//  Copyright © 2020 Алексей Воронов. All rights reserved.
//
// Share sheet by showing services, e.g. share news story by chat app or email

import SwiftUI
import UIKit

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        return activityViewController
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}

