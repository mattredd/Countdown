//
//  TimerView.swift
//  Countdown
//
//  Created by Matthew Reddin on 07/03/2021.
//

import SwiftUI

struct TimerView: View {
    
    @EnvironmentObject var countDownVM: CountdownViewModel
    let timer: CountdownTimer
    let backgroundColour: Color
    @State var shakeIndex = 0.0
    
    var body: some View {
        VStack {
            HStack {
                Text(timer.title)
                    .foregroundColor(.white)
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                Spacer()
                timerDisplay
                    .overlay(Capsule().stroke(.white, lineWidth: countDownVM.pickedtimerID == timer.id ? UIConstants.strokeWidth : 0))
                Spacer()
                timerButton
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if timer.status != .active {
                    countDownVM.showDurationPicker(id: timer.id)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .modifier(CellColourFlashModifier(shakeIndex: shakeIndex, backgroundColour: backgroundColour))
        .onChange(of: timer.status) { newValue in
            if newValue == .completed {
                withAnimation(.linear(duration: 1.5)) {
                    shakeIndex += 1
                }
            }
        }
    }
    
    var timerDisplay: some View {
        Group {
            if timer.status == .active {
                Text(timer.endTime ?? .now, style: .timer)
            } else if timer.status != .completed {
                Text("\((timer.convertDuration().minutes).formatted(.number.precision(.integerLength(1...2)))):\((timer.convertDuration().seconds.formatted(.number.precision(.integerLength(2)))))")
            } else {
                Text("Finished")
                    .font(.system(.largeTitle, design: .default).weight(.semibold))
                    .foregroundColor(.white)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .font(.system(.largeTitle, design: .monospaced).weight(.semibold))
        .foregroundColor(.white)
        .padding()
        .padding(.horizontal)
        .background(Capsule().fill(backgroundColour).shadow(radius: 5))
    }
    
    var timerButton: some View {
        Button {
            if timer.status == .completed {
                withAnimation(.spring()) {
                    countDownVM.removeTimer(id: timer.id)
                }
            } else if timer.status == .active {
                countDownVM.stopTimer(id: timer.id, at: .now)
                withAnimation(.linear) {
                    countDownVM.pickedtimerID = nil
                }
            } else {
                countDownVM.startTimer(id: timer.id)
                withAnimation(.linear) {
                    countDownVM.pickedtimerID = nil
                }
            }
        } label: {
            Image(systemName: timer.status == .completed ? "trash" : timer.status == .active ? "pause.fill" : "play.fill")
                .font(.headline)
                .foregroundColor(.white)
                .padding(UIConstants.systemSpacing * 3)
                .background(.radialGradient(colors: [backgroundColour, backgroundColour.opacity(0.01)], center: .center, startRadius: 10, endRadius: UIConstants.systemSpacing * 5))
                .clipShape(Circle())
        }
        .disabled(timer.duration == 0)
        .buttonStyle(.plain)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = CountdownViewModel(countdownManager: TimerCountdownManager())
        Group {
            TimerView(timer: CountdownTimer(id: UUID(), status: .created, title: "Test 1", duration: 20, endTime: nil, theme: 1), backgroundColour: .orange)
            TimerView(timer: CountdownTimer(id: UUID(), status: .active, title: "Test 2", duration: 60, endTime: .now.addingTimeInterval(60), theme: 1), backgroundColour: .blue)
            TimerView(timer: CountdownTimer(id: UUID(), status: .stopped, title: "Test 3", duration: 743, endTime: .now.addingTimeInterval(60), theme: 1), backgroundColour: .orange)
            TimerView(timer: CountdownTimer(id: UUID(), status: .completed, title: "Test 4", duration: 4, endTime: .now.addingTimeInterval(60), theme: 1), backgroundColour: .red)
        }
        .padding()
        .background(.red)
        .environmentObject(vm)
        .previewLayout(.fixed(width: 400, height: 100))
    }
}
