//
//  CircularText.swift
//  Countdown
//
//  Created by Matthew Reddin on 17/04/2022.
//

import SwiftUI

// Draws the text along a circular path using the radius property
struct CircularText: View {
    
    let radius: Double
    let text: String
    let textSize: Double
    
    var body: some View {
        let characters = Array(text)
        ZStack {
            ForEach(characters.indices, id: \.self) { indx in
                let angle = angleFor(index: indx)
                let offset = characterOffset(angle: angle)
                Text(String(characters[indx]))
                    .font(.system(size: textSize, weight: .semibold, design: .default))
                    .foregroundColor(Color.white)
                    .rotationEffect(angle)
                    .offset(x: offset.0, y: offset.1)
            }
        }
    }
    
    func angleFor(index: Int) -> Angle {
        Angle(degrees: (Double(index - (text.count / 2)) * textSize))
    }
    
    func characterOffset(angle: Angle) -> (Double, Double) {
        (radius * cos(angle.radians - (.pi / 2)), radius * sin(angle.radians - (.pi / 2)))
    }
}
