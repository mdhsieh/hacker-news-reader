//
//  CustomColorPicker.swift
//  HN Reader
//
//  Created by Michael Hsieh on 9/26/22.
//

import SwiftUI

struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    private let colors: [Color] = [.teal, .green, .orange, .purple, .indigo, .blue, .yellow, .pink]
    var colorData: ColorData
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(colors, id: \.self) { color in
                    
                    if (color == selectedColor && colorScheme == .dark) {
                        // White stroke circle in dark mode
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .background(Circle().fill(color))
                            // Modifiers exact same for the other circles. Should
                            // refactor to not repeat the modifiers somehow
                            .frame(width: 45, height: 45)
                            .scaleEffect(color == selectedColor ? 1.1 : 1.0)
                            .onTapGesture {
                                selectedColor = color
                                colorData.saveColor(color: selectedColor)
                            }
                    } else if (color == selectedColor) {
                        // Dark colored stroke circle in light mode
                        Circle()
                            .stroke(Color.red, lineWidth: 4)
                            .background(Circle().fill(color))
                            .frame(width: 45, height: 45)
                            .scaleEffect(color == selectedColor ? 1.1 : 1.0)
                            .onTapGesture {
                                selectedColor = color
                                colorData.saveColor(color: selectedColor)
                            }
                    }
                    else {
                        // Otherwise show a circle in that color
                        Circle()
                            .foregroundColor(color)
                            .frame(width: 45, height: 45)
                            .scaleEffect(color == selectedColor ? 1.1 : 1.0)
                            .onTapGesture {
                                selectedColor = color
                                colorData.saveColor(color: selectedColor)
                            }
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
