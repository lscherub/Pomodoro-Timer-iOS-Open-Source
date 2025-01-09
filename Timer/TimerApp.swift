//
//  TimerApp.swift
//  Timer
//
//  Created by Gilda on 01/01/23.
//

import SwiftUI
import UserNotifications

@main
struct TimerApp: App {
    init() {
            requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error requesting notification permission: \(error)")
                } else {
                    print("Notification permission granted: \(granted)")
                }
            }
    }
    
}
