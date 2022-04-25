//
//  CountdownManager.swift
//  Countdown
//
//  Created by Matthew Reddin on 03/03/2022.
//

import Foundation
import OrderedCollections

protocol CountdownManager {
    var countdownTimers: OrderedDictionary<UUID, CountdownTimer> { get }
    var remoteNotificationAuthorised: Bool { get set}
    func addTimer()
    func updateTimers()
    func removeTimer(id: UUID)
    func stopTimer(id: UUID, at date: Date)
    func startTimer(id: UUID)
    func deactiveTimers()
    func setDuration(id: UUID, duration: (minutes: Int, seconds: Int))
    func setTitle(id: UUID, title: String)
    func setBackgroundTheme(id: UUID, index: Int)
    func setTimer(timers: [CountdownTimer])
    func resetTimer(id: UUID)
}
