//
//  ContentView.swift
//  Countdown
//
//  Created by Matthew Reddin on 06/03/2021.
//

import SwiftUI
import NotificationCenter

struct MainView: View {
    
    @EnvironmentObject var countdownVM: CountdownViewModel
    let colours = [Color.orange, .red, .blue, .purple, .mint]
    
    var body: some View {
        NavigationView {
            ScrollViewReader { readerProxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(countdownVM.timers.values, id: \.id) { timer in
                            TimerView(timer: timer, backgroundColour: colours[timer.theme])
                                .overlay(
                                    Rectangle()
                                        .fill(Color(uiColor: .systemBackground))
                                        .frame(height: UIConstants.strokeWidth), alignment: .bottom)
                        }
                    }
                }
                .overlay(
                    Group {
                        if countdownVM.timers.isEmpty {
                            Text("To add a countdown, tap the plus button at the top of the screen.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                )
                .animation(.spring(), value: countdownVM.pickedtimerID)
                .safeAreaInset(edge: .bottom) {
                    Group {
                        if let _ = countdownVM.pickedtimerID, let durationBinding = countdownVM.durationBinding, let titleBinding = countdownVM.titleBinding, let themeBinding = countdownVM.themeBinding {
                            DurationChangerView(themeIndex: themeBinding, duration: durationBinding, titleBinding: titleBinding, colours: colours)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                                .background(Color(.secondarySystemBackground).ignoresSafeArea(.all, edges: .all))
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .zIndex(1)
                        }
                    }
                }
                .onReceive(countdownVM.$pickedtimerID) {
                    if let selectedID = $0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                            withAnimation(.spring()) {
                                readerProxy.scrollTo(selectedID, anchor: .top)
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                        Button {
                            withAnimation(.spring()) {
                                countdownVM.addTimer()
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .navigationBarTitle("Countdown", displayMode: .inline)
        }
    }
}
