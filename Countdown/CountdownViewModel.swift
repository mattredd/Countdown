//
//  CountdownViewModel.swift
//  Countdown
//
//  Created by Matthew Reddin on 07/03/2021.
//

import SwiftUI
import Combine
import Collections
import AudioToolbox

class CountdownViewModel: ObservableObject {
    
    @Published var pickedtimerID: UUID?
    var countdownManager: CountdownManager
    var durationBinding: Binding<(Int, Int)>?
    var titleBinding: Binding<String>?
    var themeBinding: Binding<Int>?
    var notificationToken: NSObjectProtocol?
    var cancellables: Set<AnyCancellable> = []
    var timers: OrderedDictionary<UUID, CountdownTimer> {
        countdownManager.countdownTimers
    }
    var timerDocumentURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("timers.dat")
    }()
    
    init(countdownManager: CountdownManager) {
        self.countdownManager = countdownManager
        if FileManager.default.fileExists(atPath: timerDocumentURL.path) {
            if let timerData = try? Data(contentsOf: timerDocumentURL), let timer = try? JSONDecoder().decode([CountdownTimer].self, from: timerData) {
                countdownManager.setTimer(timers: timer)
            }
        }
        notificationToken = NotificationCenter.default.addObserver(forName: .timerFinished, object: countdownManager, queue: .main) { [weak self] notification in
            withAnimation(.spring()) {
                self?.objectWillChange.send()
            }
            self?.saveTimers()
        }
        $pickedtimerID.sink { [weak self] _ in
            self?.saveTimers()
        }.store(in: &cancellables)
    }
    
    deinit {
        if let notificationToken = notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
        saveTimers()
    }
    
    func addTimer() {
        objectWillChange.send()
        countdownManager.addTimer()
        if let id = countdownManager.countdownTimers.keys.last {
            showDurationPicker(id: id)
        }
        saveTimers()
    }
    
    func startTimer(id: UUID) {
        objectWillChange.send()
        countdownManager.startTimer(id: id)
        saveTimers()
    }
    
    func stopTimer(id: UUID, at date: Date) {
        objectWillChange.send()
        countdownManager.stopTimer(id: id, at: date)
        saveTimers()
    }
    
    func removeTimer(id: UUID) {
        objectWillChange.send()
        countdownManager.removeTimer(id: id)
        saveTimers()
    }
    
    func resetTimer(id: UUID) {
        objectWillChange.send()
        countdownManager.resetTimer(id: id)
        saveTimers()
    }
    
    func showDurationPicker(id: UUID) {
        guard countdownManager.countdownTimers[id] != nil else { return }
        // Create the bindings so that the countdown modifier view can update the countdown's properties when presented
        durationBinding = Binding(get: { [weak self] in
            self?.countdownManager.countdownTimers[id]?.convertDuration() ?? (1, 60)
        }, set: { [weak self] newValue in
            self?.objectWillChange.send()
            self?.countdownManager.setDuration(id: id, duration: newValue)
        })
        titleBinding = Binding(get: { [unowned self] in
            self.countdownManager.countdownTimers[id]?.title ?? ""
        }, set: { [weak self] in
            self?.objectWillChange.send()
            self?.countdownManager.setTitle(id: id, title: $0)
        })
        themeBinding = Binding(get: { [unowned self] in
            self.countdownManager.countdownTimers[id]?.theme ?? 0
        }, set: { [weak self] in
            self?.objectWillChange.send()
            self?.countdownManager.setBackgroundTheme(id: id, index: $0)
        })
        withAnimation(.spring()) {
            pickedtimerID = id
        }
    }
    
    func enterBackground() {
        countdownManager.deactiveTimers()
        saveTimers()
    }
    
    func enterForeground() {
        countdownManager.updateTimers()
        saveTimers()
    }
    
    func saveTimers() {
        if let jsonData = try? JSONEncoder().encode(Array(countdownManager.countdownTimers.values)) {
            try? jsonData.write(to: timerDocumentURL)
        }
    }

}
