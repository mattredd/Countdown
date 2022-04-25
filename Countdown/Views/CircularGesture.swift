//
//  CircularGesture.swift
//  Countdown
//
//  Created by Matthew Reddin on 18/04/2022.
//

import SwiftUI

// A gesture that will rotate a circle as you drag in the circle.
struct CircularGesture: Gesture {
    
    @State var lastPoint: CGPoint?
    @State var startingDuration: Int?
    @Binding var startingValue: Double
    @Binding var duration: Int
    @Binding var rotationAngle: Double
    let isSeconds: Bool
    let circleRadius: Double
    let circleInset: Double
    
    var body: some Gesture {
        DragGesture()
            .onChanged { val in
                guard let lastTouchLocation = lastPoint else {
                    startingValue = 0
                    startingDuration = duration
                    lastPoint = val.location
                    return
                }
                // Calculate the new angle of the circle
                let adjacent = val.location.x - circleRadius
                let opposite = circleRadius - val.location.y
                let hypotenuse = sqrt(adjacent * adjacent + opposite * opposite)
                // Make sure that the touch is within the correct circle
                if !isSeconds {
                    guard hypotenuse >= circleRadius - circleInset && hypotenuse <= circleRadius else { return }
                } else {
                    guard hypotenuse < circleRadius - circleInset else { return }
                }
                let lastTouchAdjcent = lastTouchLocation.x - circleRadius
                let lastTouchOpposite = circleRadius - lastTouchLocation.y
                var angle = atan2(lastTouchAdjcent, lastTouchOpposite) - atan2(adjacent, opposite)
                // Modify the angle if it is over 180° or -180° (the user in the middle of the drag moved their finger away from the circle and after a time moved their finger back onto the view)
                if angle > .pi {
                    angle = angle - 2 * .pi
                } else if angle < -.pi {
                    angle = angle + 2 * .pi
                }
                startingValue -= Double(angle)
                rotationAngle -= Double(angle)
                duration = calculateDuration(from: angle)
                lastPoint = val.location
                }
            .onEnded { _ in
                lastPoint = nil
            }
    }
    
    func calculateDuration(from angle: Double) -> Int {
        let newDuration = startingDuration! + (Int(startingValue * 10))
        if newDuration > 59 {
            startingDuration = 0
            startingValue = 0
            return 0
        } else if newDuration < 0 {
            startingDuration = 59
            startingValue = 0
            return 59
        } else {
            return newDuration
        }
    }
}


