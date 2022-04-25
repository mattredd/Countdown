//
//  ColourPickerView.swift
//  Countdown
//
//  Created by Matthew Reddin on 11/04/2022.
//

import SwiftUI

struct ThemeColourPickerView: View {
    
    @Binding var themeIndex: Int
    let colours: [Color]
    let circleSize = 30.0
    
    var body: some View {
        HStack {
            ForEach(Array(colours.indices), id: \.self) { indx in
                Circle()
                    .fill(colours[indx])
                    .frame(width: circleSize, height: circleSize)
                    .overlay(Circle().inset(by: -2).strokeBorder(.black, lineWidth: UIConstants.strokeWidth).offset(x: -1, y: -1).blur(radius: 3))
                    .overlay(
                        Group {
                            if indx == themeIndex {
                                Circle()
                                    .strokeBorder(Color.primary.opacity(0.6), lineWidth: UIConstants.strokeWidth)
                            }
                        }
                    )
                    .clipShape(Circle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            themeIndex = indx
                        }
                    }
            }
        }
    }
}
