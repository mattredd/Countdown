//
//  CounterDownTimer.swift
//  Countdown
//
//  Created by Matthew Reddin on 08/03/2021.
//

import Foundation
import SwiftUI

struct CountdownTimer: Identifiable, Codable {
    
    enum CountdownStatus: Codable {
        case created, active, stopped, completed
    }
    
    let id: UUID
    var status = CountdownStatus.created
    var title: String
    var duration: Double
    var endTime: Date?
    var startTime: Date?
    var startingDuration: Double?
    var theme = 0
    
    func convertDuration() -> (minutes: Int, seconds: Int) {
        let mins = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return (mins, seconds)
    }
    
    mutating func resetTimer() {
        status = .created
        duration = startingDuration ?? 60
        endTime = nil
        startTime = nil
    }
    
    mutating func startTimer() {
        if status == .created {
            startingDuration = duration
        }
        let nowTime = Date.now
        endTime = nowTime.addingTimeInterval(duration)
        startTime = nowTime
        status = .active
    }
    
    mutating func stopTimer(at date: Date) {
        status = .stopped
        duration = max(Double.leastNonzeroMagnitude, endTime!.timeIntervalSince(date))
        endTime = nil
    }
    
    mutating func setDuration(_ duration: Double) {
        self.duration = duration
    }
    
    mutating func countdownFinished() {
        status = .completed
        endTime = nil
    }
}
