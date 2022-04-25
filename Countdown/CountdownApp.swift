//
//  CountdownApp.swift
//  Countdown
//
//  Created by Matthew Reddin on 06/03/2021.
//

import SwiftUI
import NotificationCenter

@main
struct CountdownApp: App {
    
    @StateObject var countdownVM = CountdownViewModel(countdownManager: TimerCountdownManager())
    @Environment(\.scenePhase) var appStatus
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(countdownVM)
                .onChange(of: appStatus) { phase in
                    if phase == .active {
                        countdownVM.enterForeground()
                    } else if phase == .background {
                        countdownVM.enterBackground()
                    }
                }
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { authorised, error in
                        countdownVM.countdownManager.remoteNotificationAuthorised = authorised
                    }
                }
        }
    }
}
