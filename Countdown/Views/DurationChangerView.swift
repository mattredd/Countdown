//
//  CircularTimerSetterView.swift
//  Countdown
//
//  Created by Matthew Reddin on 09/03/2021.
//

import SwiftUI

struct DurationChangerView: View {
    
    @EnvironmentObject var countdownVM: CountdownViewModel
    @State var rotationSeconds: Double = -.pi
    @State var rotationMinutes: Double = -.pi
    @State var startingValue: Double = 0
    @Binding var themeIndex: Int
    @Binding var duration: (Int, Int)
    @Binding var titleBinding: String
    let circleInset: CGFloat = 50
    let circleSize: CGFloat = 280
    let colours: [Color]
    
    var body: some View {
        VStack {
            Button {
                withAnimation(.spring()) {
                    countdownVM.pickedtimerID = nil
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.primary)
                    .symbolRenderingMode(.hierarchical)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            durationModifierCircle
            headerSection
            buttonsSection
            ThemeColourPickerView(themeIndex: $themeIndex, colours: colours)
        }
    }
    
    var durationModifierCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.white, lineWidth: UIConstants.strokeWidth)
                .background(Circle().fill(colours[themeIndex]).contrast(0.9))
                .gesture(CircularGesture(startingValue: $startingValue, duration: $duration.0, rotationAngle: $rotationMinutes, isSeconds: false, circleRadius: circleSize / 2, circleInset: circleInset))
            Circle()
                .inset(by: circleInset)
                .overlay(Circle().inset(by: circleInset).fill(colours[themeIndex]))
                .overlay(Circle().inset(by: circleInset).strokeBorder(.white, lineWidth: 2))
                .gesture(CircularGesture(startingValue: $startingValue, duration: $duration.1, rotationAngle: $rotationSeconds, isSeconds: true, circleRadius: circleSize / 2, circleInset: circleInset))
            CircularText(radius: Double(circleSize - circleInset) / 2, text: "MINUTES", textSize: circleInset * 0.5)
                .rotationEffect(.radians(rotationMinutes))
            Text("SECONDS")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .kerning(5)
                .foregroundColor(Color.white)
                .rotationEffect(.radians(rotationSeconds))
                .allowsHitTesting(false)
        }
        .frame(width: circleSize, height: circleSize)
    }
    
    var headerSection: some View {
        HStack(spacing: 0) {
            TextField("Timer Title", text: $titleBinding)
                .padding(UIConstants.systemSpacing)
                .background(Color(.tertiarySystemBackground).cornerRadius(10))
                .padding(.horizontal)
        }
    }
    
    var buttonsSection: some View {
        HStack {
            Button(role: .destructive) {
                if let id = countdownVM.pickedtimerID {
                    withAnimation(.spring()) {
                        countdownVM.pickedtimerID = nil
                        countdownVM.removeTimer(id: id)
                    }
                }
            } label: {
                Text("Delete")
            }
            .buttonStyle(.bordered)
            Button() {
                if let id = countdownVM.pickedtimerID {
                    withAnimation(.spring()) {
                        countdownVM.resetTimer(id: id)
                    }
                }
            } label: {
                Text("Reset")
            }
            .buttonStyle(.bordered)
            .onAppear {
                withAnimation(.spring()) {
                    rotationSeconds = 0
                    rotationMinutes = 0
                }
            }
            .onChange(of: countdownVM.pickedtimerID) { newValue in
                withAnimation(.spring()) {
                    rotationSeconds = 0
                    rotationMinutes = 0
                }
            }
        }
    }
}
