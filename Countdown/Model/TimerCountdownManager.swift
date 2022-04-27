//
//  TimerCountdownManager.swift
//  Countdown
//
//  Created by Matthew Reddin on 03/03/2022.
//

import Foundation
import UserNotifications
import OrderedCollections
import AudioToolbox

// An object which uses the Foundation Timer object to notify the system that a countdown has finished
class TimerCountdownManager: CountdownManager {
    
    private(set) var countdownTimers: OrderedDictionary<UUID, CountdownTimer> = [:]
    // The timers that will notify the system to update the model when the countdown has finished
    private var timers: [UUID : Timer] = [:]
    var remoteNotificationAuthorised = false
    
    func startTimer(id: UUID) {
        guard let timer = countdownTimers[id] else { return }
        countdownTimers[id]?.startTimer()
        timers[id] = Timer.scheduledTimer(timeInterval: timer.duration, target: self, selector: #selector(countdownFinished(notification:)), userInfo: ["id": timer.id, TimerCompletionNotificationKeys.sound : true], repeats: false)
        if remoteNotificationAuthorised {
            setupLocalNotification(timer: timer)
        }
    }
    
    func resetTimer(id: UUID) {
        countdownTimers[id]?.resetTimer()
        timers[id]?.invalidate()
        timers[id] = nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    func setupLocalNotification(timer: CountdownTimer) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timer.duration, repeats: false)
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = timer.title
        content.body = "Countdown has ended"
        let request = UNNotificationRequest(identifier: timer.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func addTimer() {
        let newTimer = CountdownTimer(id: UUID(), title: "Count\u{AD}down", duration: 60)
        countdownTimers[newTimer.id] = newTimer
    }
    
    func updateTimers() {
        for i in countdownTimers.keys {
            guard let timer = countdownTimers[i], let end = timer.endTime, timer.status == .active else { continue }
            if end < .now {
                let notification = NSNotification(name: .timerFinished, object: self, userInfo: [TimerCompletionNotificationKeys.id: timer.id, TimerCompletionNotificationKeys.sound : false])
                countdownFinished(notification: notification)
            } else {
                timers[i] = Timer.scheduledTimer(timeInterval: end.timeIntervalSince(.now), target: self, selector: #selector(countdownFinished(notification:)), userInfo: [TimerCompletionNotificationKeys.id: timer.id, TimerCompletionNotificationKeys.sound : true], repeats: false)
            }
        }
    }
    
    @objc
    func countdownFinished(notification: NSNotification) {
        if (notification.userInfo?[TimerCompletionNotificationKeys.sound] as? Bool) == true {
            AudioServicesPlayAlertSound(AppConstants.audioToolboxAlertSound)
        }
        guard let id = notification.userInfo?[TimerCompletionNotificationKeys.id] as? UUID else { return }
        timers[id]?.invalidate()
        timers[id] = nil
        countdownTimers[id]?.countdownFinished()
        NotificationCenter.default.post(name: .timerFinished, object: self)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    func removeTimer(id: UUID) {
        countdownTimers[id] = nil
        timers[id]?.invalidate()
        timers[id] = nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    func stopTimer(id: UUID, at date: Date) {
        guard countdownTimers[id]?.status == .active else { return }
        countdownTimers[id]?.stopTimer(at: date)
        timers[id]?.invalidate()
        timers[id] = nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    func deactiveTimers() {
        for i in timers.keys  {
            timers[i]?.invalidate()
            timers[i] = nil
        }
    }
    
    func setTimer(timers: [CountdownTimer]) {
        for timer in timers {
            countdownTimers[timer.id] = timer
        }
        updateTimers()
    }
}
extension TimerCountdownManager {
    
    // Methods to adjust the countdown so that viewmodel can use them to create bindings
    
    func setDuration(id: UUID, duration: (minutes: Int, seconds: Int)) {
        countdownTimers[id]?.setDuration(Double(duration.minutes * 60 + duration.seconds))
    }
    
    func setBackgroundTheme(id: UUID, index: Int) {
        countdownTimers[id]?.theme = index
    }
    
    func setTitle(id: UUID, title: String) {
        countdownTimers[id]?.title = title
    }
}
