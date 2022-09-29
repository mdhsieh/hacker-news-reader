//
//  SheetManager.swift
//  HN Reader
//
//  Created by Michael Hsieh on 9/28/22.
//
// Put the selected item in an ObservableObject class because
// sheet will be blank on first tap in iOS < 16 if using @State. Need @StateObject to work
// https://stackoverflow.com/questions/65779160/swiftui-sheet-is-blank-on-first-tap-but-works-correctly-afterwards

import SwiftUI

class SheetMananger: ObservableObject {
    @Published var shouldShowShareSheet = false
    @Published var selectedItem: Item? = nil
}
