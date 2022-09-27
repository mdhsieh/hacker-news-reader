//
//  ColorData.swift
//  HN Reader
//
//  Created by Michael Hsieh on 9/27/22.
//
// Represent a color as an array of RGB values, in order to save in user defaults

import Foundation
import SwiftUI

struct ColorData {
    private var COLOR_KEY = "COLOR_KEY"
    private let userDefaults = UserDefaults.standard
    
    func saveColor(color:Color) {
        let color = UIColor(color).cgColor
        
        if let components = color.components {
            userDefaults.set(components, forKey: COLOR_KEY)
            print(components)
            print("Color saved")
        }
    }
    
    func loadColor() -> Color {
        guard let array = userDefaults.object(forKey: COLOR_KEY) as? [CGFloat] else {
            // Default color
            return Color.teal
        }
        
        let color = Color(.sRGB,
                          red: array[0],
                          green: array[1],
                          blue: array[2],
                          opacity: array[3])
        
        print(color)
        print("color loaded")
        return color
    }
}
