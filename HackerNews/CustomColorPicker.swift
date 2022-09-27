//
//  CustomColorPicker.swift
//  HN Reader
//
//  Created by Michael Hsieh on 9/26/22.
//

import SwiftUI

struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    private let colors: [Color] = [.teal, .green, .orange, .purple, .indigo, .blue, .yellow, .pink, .red]
    var colorData: ColorData
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(colors, id: \.self) { color in
                    Circle().foregroundColor(color)
                        .frame(width: 45, height: 45)
                        .opacity(color == selectedColor ? 0.5 : 1.0)
                        .scaleEffect(color == selectedColor ? 1.1 : 1.0)
                        .onTapGesture {
                            selectedColor = color
                            print("Changed color to \(selectedColor.description)")
                            colorData.saveColor(color: selectedColor)
                        }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}

struct CustomColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomColorPicker(selectedColor: .constant(.blue), colorData: ColorData())
    }
}
