//
//  AppConstants.swift
//  Countdown
//
//  Created by Matthew Reddin on 07/03/2022.
//

import Foundation

struct AppConstants {
    // Taken from https://github.com/TUNER88/iOSSystemSoundsLibrary
    static let audioToolboxAlertSound: UInt32 = 1005
}

struct TimerCompletionNotificationKeys {
    static let id = "id"
    static let sound = "sound"
}

extension Notification.Name {
    static let timerFinished = Notification.Name("timerFinished")
}
