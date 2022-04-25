//
//  CellColourFlashEffect.swift
//  Countdown
//
//  Created by Matthew Reddin on 18/04/2022.
//

import SwiftUI

struct CellColourFlashModifier: AnimatableModifier {
    
    var shakeIndex: Double
    let backgroundColour: Color
    let frequency = 8.0
    
    var animatableData: Double {
        get {
            return shakeIndex
        }
        set {
            shakeIndex = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(.linearGradient(colors: [backgroundColour, backgroundColour.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
            .opacity(1 - (sin(shakeIndex.truncatingRemainder(dividingBy: 1) * .pi * frequency - (.pi * 0.5)) * 0.5 + 0.5))
    }
}
