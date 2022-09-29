//
//  FavoriteSheetManager.swift
//  HN Reader
//
//  Created by Michael Hsieh on 9/28/22.
//

import SwiftUI

class FavoriteSheetMananger: ObservableObject {
    @Published var shouldShowShareSheet = false
    @Published var selectedItem: FavoriteItem? = nil
}
