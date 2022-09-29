//
//  SheetManager.swift
//  HN Reader
//
//  Created by Michael Hsieh on 9/28/22.
//

import SwiftUI

class SheetMananger: ObservableObject {
    @Published var shouldShowShareSheet = false
    @Published var selectedItem: Item? = nil
}
